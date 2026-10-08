import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/postprocessing/face_detector_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/preprocessing/face_detector_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/face_landmarks_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/head_pose_estimator.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/iqa/preprocessing/iqa_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_crop/face_crop_helper.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';
import 'package:dataspikemobilesdk/face_detector/ml_processing/brightness_checker/brightness_checker.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';

class FacePipeline {
  late Interpreter _faceDetector;
  late Interpreter _faceLandmarks;
  late Interpreter _iqa;

  /// IQA score above which a frame counts as blurry (0 = sharp, 1 = blurry).
  static const double blurThreshold = 0.55;

  /// Consecutive blurry frames needed before the frame is flagged blurry.
  static const int blurryFramesToFlag = 4;

  /// Minimum landmarks-model face presence probability.
  static const double facePresenceThreshold = 0.5;

  List<List<double>> _canonical = [];
  int _blurryFrames = 0;

  // Exponential pose smoothing across frames (POSE_SMOOTH_ALPHA in the
  // reference pipeline).
  static const double _poseSmoothAlpha = 0.5;
  Map<String, double>? _smoothedPose;

  /// Wall time per stage of the last [analyze] call, in ms (profiling).
  final Map<String, double> lastTimingsMs = {};
  final Stopwatch _stageClock = Stopwatch();

  void _lap(String stage) {
    lastTimingsMs[stage] = _stageClock.elapsedMicroseconds / 1000;
    _stageClock
      ..reset()
      ..start();
  }

  void resetState() {
    _blurryFrames = 0;
    _smoothedPose = null;
  }

  Map<String, double> _smoothPose(Map<String, double> p) {
    final prev = _smoothedPose;
    if (prev == null) return _smoothedPose = Map.of(p);
    return _smoothedPose = {
      for (final k in const ['pitch', 'yaw', 'roll'])
        k: _poseSmoothAlpha * p[k]! + (1 - _poseSmoothAlpha) * prev[k]!,
    };
  }

  // Default interpreter options run on very few CPU threads. Apple
  // silicon's strong single-core performance hides this, but on Android
  // (weaker single-core, more cores) it leaves most of the CPU idle
  // during inference. Spread the work across cores instead — but fall
  // back to the plain default if the multi-threaded option ever fails
  // to create on a given device, since a slower pipeline beats a
  // liveness screen that never initializes at all.
  //
  // On iOS, additionally try the Metal GPU delegate first (full FP32
  // precision, not the lower-precision fast path) before falling back to
  // CPU-only, since GPU execution can meaningfully beat even a
  // multi-threaded CPU run for these conv-heavy models.
  static Interpreter _createInterpreter(Uint8List bytes) {
    final threads = math.min(4, math.max(1, Platform.numberOfProcessors));

    if (Platform.isIOS) {
      try {
        final options = InterpreterOptions()..threads = threads;
        options.addDelegate(
          GpuDelegate(options: GpuDelegateOptions(allowPrecisionLoss: false)),
        );
        return Interpreter.fromBuffer(bytes, options: options);
      } catch (_) {
        // Unsupported op, delegate creation failure, etc. — fall through
        // to the CPU-only paths below.
      }
    }

    try {
      return Interpreter.fromBuffer(
        bytes,
        options: InterpreterOptions()..threads = threads,
      );
    } catch (_) {
      return Interpreter.fromBuffer(bytes);
    }
  }

  static Future<FacePipeline> createFromBytes({
    required Uint8List detectorBytes,
    required Uint8List landmarksBytes,
    required String canonicalData,
    required Uint8List iqaBytes,
  }) async {
    final pipeline = FacePipeline();

    pipeline._faceDetector = _createInterpreter(detectorBytes);
    pipeline._faceLandmarks = _createInterpreter(landmarksBytes);
    pipeline._iqa = _createInterpreter(iqaBytes);

    pipeline._canonical = await _parseCanonical(canonicalData);

    return pipeline;
  }

  /// Runs [interpreter] on a flat float32 input and returns every output
  /// tensor as a flat Float32List (copied out of native memory).
  ///
  /// Raw bytes go straight into the tensor. Passing nested Lists (reshape)
  /// instead makes tflite_flutter convert each element through its own
  /// ByteData — ~350k allocations per frame here, which cost seconds per
  /// frame on mid-range Android.
  static List<Float32List> _infer(Interpreter interpreter, Float32List input) {
    interpreter.runInference([input.buffer]);
    return [
      for (final tensor in interpreter.getOutputTensors())
        Float32List.fromList(
          tensor.data.buffer.asFloat32List(
            tensor.data.offsetInBytes,
            tensor.data.lengthInBytes ~/ 4,
          ),
        ),
    ];
  }

  static Future<List<List<double>>> _parseCanonical(String data) async {
    final verts = <List<double>>[];
    for (final line in data.split('\n')) {
      if (line.startsWith('v ')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        verts.add([
          double.parse(parts[1]),
          double.parse(parts[2]),
          double.parse(parts[3]),
        ]);
      }
    }
    return verts;
  }

  Future<FaceAnalysisResult?> analyze(
    img.Image inputImage, {
    AvatarCropRect? avatarRect,
  }) => analyzeFrame(RgbFrame.fromImage(inputImage), avatarRect: avatarRect);

  Future<FaceAnalysisResult?> analyzeFrame(
    RgbFrame fullFrame, {
    AvatarCropRect? avatarRect,
  }) async {
    // Everything below runs on the avatar-mask crop — the same pixels that
    // get uploaded — so chin/forehead/size checks match the server's view.
    lastTimingsMs.clear();
    _stageClock
      ..reset()
      ..start();
    final frame = avatarRect == null
        ? fullFrame
        : fullFrame.crop(
            avatarRect.x,
            avatarRect.y,
            avatarRect.x + avatarRect.w,
            avatarRect.y + avatarRect.h,
          );
    final origH = frame.height;
    final origW = frame.width;

    // The face is detected on every frame (as in production): the 128x128
    // detector is cheap, and a cached box goes stale as soon as the user
    // moves, which skews every landmark-based check.
    _lap('crop');
    // face_detector.tflite (v4): regressors [1,896,16], classificators [1,896,1]
    final detectorOut = _infer(
      _faceDetector,
      FaceDetectorPreprocessor.preprocess(frame),
    );
    final detectedFaces = FaceDetectorPostprocessor.postprocess(
      detectorOut[0],
      detectorOut[1],
      origW,
      origH,
    );
    _lap('detector');
    if (detectedFaces.isEmpty) return null;

    // Production keeps the largest face, not the highest-scoring one.
    double area(Map<String, dynamic> f) {
      final b = f['box'] as Map<String, dynamic>;
      return ((b['xMax'] as double) - (b['xMin'] as double)) *
          ((b['yMax'] as double) - (b['yMin'] as double));
    }

    final bestFace = detectedFaces.reduce((a, b) => area(b) > area(a) ? b : a);

    final box = bestFace['box'] as Map<String, dynamic>;

    final kps = bestFace['keypoints'] as List<Map<String, double>>;
    const ldH = 256;
    const ldW = 256;

    final (:input, :mInv, :roiSize) = FaceCropHelper.cropFaceRoi(
      frame,
      box,
      kps,
      ldH,
      ldW,
    );

    _lap('landmarksCrop');
    // face_landmarks_detector.tflite (v4): Identity [1,1,1,1434],
    // Identity_1 [1,1,1,1] (face flag), Identity_2 [1,1]
    final landmarksOut = _infer(_faceLandmarks, input);

    final landmarksResult = FaceLandmarksPostprocessor.postprocess(
      landmarksOut[0],
      landmarksOut[1][0],
      ldW,
      ldH,
    );

    final facePresenceScore = landmarksResult['facePresenceScore'] as double;
    _lap('landmarksModel');
    if (facePresenceScore < facePresenceThreshold) return null;

    final landmarks = landmarksResult['landmarks'] as List<Map<String, double>>;

    final lmOrig = HeadPoseEstimator.mapLandmarksToOriginal(
      landmarks,
      mInv,
      ldW,
      ldH,
    );

    final rawPose = HeadPoseEstimator.estimate(
      landmarks,
      lmOrig,
      _canonical,
      roiSize,
      origH,
      origW,
    );
    final headPose = rawPose == null ? null : _smoothPose(rawPose);
    _lap('pose');

    final isHeadPoseOk =
        headPose != null && HeadPoseEstimator.isAcceptable(headPose);

    final eyeStatus = FaceLandmarksPostprocessor.checkEyesClosedFromPixels(
      lmOrig,
    );
    final ears = FaceLandmarksPostprocessor.eyeAspectRatios(lmOrig);

    final absoluteBox = FaceBoundingBox(
      xMin: box['xMin'] as double,
      yMin: box['yMin'] as double,
      xMax: box['xMax'] as double,
      yMax: box['yMax'] as double,
    );

    // IQA (and illumination) run on a landmark-based box, extended upwards
    // by 10% of its height — same as analyze_selfies.py / face_analyzer.py.
    double lmMinX = double.infinity, lmMaxX = double.negativeInfinity;
    double lmMinY = double.infinity, lmMaxY = double.negativeInfinity;
    for (final p in lmOrig) {
      if (p[0] < lmMinX) lmMinX = p[0];
      if (p[0] > lmMaxX) lmMaxX = p[0];
      if (p[1] < lmMinY) lmMinY = p[1];
      if (p[1] > lmMaxY) lmMaxY = p[1];
    }
    final cropX1 = math.max(0, lmMinX.truncate());
    final cropX2 = math.min(origW, lmMaxX.truncate());
    final cropY2 = math.min(origH, lmMaxY.truncate());
    final lmTop = lmMinY.truncate();
    final cropY1 = math.max(0, lmTop - ((cropY2 - lmTop) / 10).floor());
    if (cropX2 <= cropX1 || cropY2 <= cropY1) return null;
    final faceCrop = frame.crop(cropX1, cropY1, cropX2, cropY2);

    final brightness = BrightnessChecker.check(faceCrop);
    _lap('brightness');
    final isTooBright = BrightnessChecker.isTooBright(brightness);
    final isTooDark = BrightnessChecker.isTooDark(brightness);

    // Sigmoid is baked into the model: 0 = sharp, 1 = blurry.
    final blurScore = _infer(_iqa, IQAPreprocessor.preprocess(faceCrop))[0][0];
    _lap('iqa');

    if (blurScore > blurThreshold) {
      _blurryFrames++;
    } else {
      _blurryFrames = 0;
    }

    final isBlurry = _blurryFrames >= blurryFramesToFlag;

    final chinVisible = FaceLandmarksPostprocessor.isChinVisible(
      lmOrig,
      origW.toDouble(),
      origH.toDouble(),
      box,
    );

    final foreheadVisible = FaceLandmarksPostprocessor.isForeheadVisible(
      lmOrig,
      origW.toDouble(),
      origH.toDouble(),
    );

    return FaceAnalysisResult(
      detectionScore: bestFace['score'] as double,
      facePresenceScore: facePresenceScore,
      blurryFrames: _blurryFrames,
      landmarks: landmarks,
      headPose: headPose,
      isHeadPoseAcceptable: isHeadPoseOk,
      eyeStatus: eyeStatus,
      boundingBox: absoluteBox,
      isBlurry: isBlurry,
      isChinVisible: chinVisible,
      isForeheadVisible: foreheadVisible,
      isTooBright: isTooBright,
      isTooDark: isTooDark,
      blurScore: blurScore,
      brightRatio: brightness['brightRatio']!,
      darkRatio: brightness['darkRatio']!,
      leftEar: ears.left,
      rightEar: ears.right,
    );
  }

  void dispose() {
    _faceDetector.close();
    _faceLandmarks.close();
    _iqa.close();
  }
}
