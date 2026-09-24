import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/postprocessing/face_detector_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/preprocessing/face_detector_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/face_landmarks_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/preprocessing/face_landmarks_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/head_pose_estimator.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/iqa/preprocessing/iqa_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_crop/face_crop_helper.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:dataspikemobilesdk/face_detector/ml_processing/brightness_checker/brightness_checker.dart';

class FacePipeline {
  late Interpreter _faceDetector;
  late Interpreter _faceLandmarks;
  late Interpreter _iqa;

  late final List<List<List<double>>> _boxCoords1;
  late final List<List<List<double>>> _boxCoords2;
  late final List<List<List<double>>> _boxScores1;
  late final List<List<List<double>>> _boxScores2;
  late final List<List<List<double>>> _landmarksTensor;
  late final List<double> _scoresTensor;

  List<List<double>> _canonical = [];
  int _blurryFrames = 0;

  Map<String, dynamic>? _trackedFace;
  int _framesSinceDetection = 0;
  static const int _redetectEveryNFrames = 5;

  void resetState() {
    _trackedFace = null;
    _framesSinceDetection = _redetectEveryNFrames;
    _blurryFrames = 0;
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

    pipeline._boxCoords1 = List.generate(
      1,
      (_) => List.generate(512, (_) => List.filled(16, 0.0)),
    );
    pipeline._boxCoords2 = List.generate(
      1,
      (_) => List.generate(384, (_) => List.filled(16, 0.0)),
    );
    pipeline._boxScores1 = List.generate(
      1,
      (_) => List.generate(512, (_) => List.filled(1, 0.0)),
    );
    pipeline._boxScores2 = List.generate(
      1,
      (_) => List.generate(384, (_) => List.filled(1, 0.0)),
    );
    pipeline._landmarksTensor = List.generate(
      1,
      (_) => List.generate(468, (_) => List.filled(3, 0.0)),
    );
    pipeline._scoresTensor = List.filled(1, 0.0);

    return pipeline;
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
    double cropRatio = 0.0,
  }) async {
    final origH = inputImage.height;
    final origW = inputImage.width;
    final scale = math.min(256 / origH, 256 / origW);

    if (_trackedFace == null ||
        _framesSinceDetection >= _redetectEveryNFrames) {
      final detectorInput = FaceDetectorPreprocessor.preprocess(inputImage);
      _faceDetector.runForMultipleInputs(
        [
          detectorInput.reshape([1, 256, 256, 3]),
        ],
        {0: _boxCoords1, 1: _boxCoords2, 2: _boxScores1, 3: _boxScores2},
      );
      final detectedFaces = FaceDetectorPostprocessor.postprocess(
        _boxCoords1,
        _boxCoords2,
        _boxScores1,
        _boxScores2,
        scale,
      );
      if (detectedFaces.isEmpty) {
        _trackedFace = null;
        return null;
      }
      _trackedFace = detectedFaces.first;
      _framesSinceDetection = 0;
    } else {
      _framesSinceDetection++;
    }

    final bestFace = _trackedFace!;

    final box = bestFace['box'] as Map<String, dynamic>;

    final kps = bestFace['keypoints'] as List<Map<String, double>>;
    final ldH = 256;
    final ldW = 256;

    final (:patch, :mInv) = FaceCropHelper.cropFaceRoi(
      inputImage,
      box,
      kps,
      ldH,
      ldW,
    );

    final landmarksInput = FaceLandmarksPreprocessor.preprocess(patch);

    _faceLandmarks.runForMultipleInputs(
      [
        landmarksInput.reshape([1, 192, 192, 3]),
      ],
      {0: _scoresTensor, 1: _landmarksTensor},
    );

    final facePresenceScore = _scoresTensor[0];
    if (facePresenceScore < 0.5) return null;

    final landmarksResult = FaceLandmarksPostprocessor.postprocess(
      _landmarksTensor,
      _scoresTensor,
    );

    final landmarks = landmarksResult['landmarks'] as List<Map<String, double>>;

    final headPose = HeadPoseEstimator.estimate(
      landmarks,
      mInv,
      _canonical,
      Platform.isAndroid ? inputImage.width : inputImage.height,
      Platform.isAndroid ? inputImage.height : inputImage.width,
      ldW,
      ldH,
    );

    final isHeadPoseOk =
        headPose != null && HeadPoseEstimator.isAcceptable(headPose);

    final lmOrig = HeadPoseEstimator.mapLandmarksToOriginal(
      landmarks,
      mInv,
      ldW,
      ldH,
    );
    final eyeStatus = FaceLandmarksPostprocessor.checkEyesClosedFromPixels(
      lmOrig,
    );

    final absoluteBox = FaceBoundingBox(
      xMin: box['xMin'] as double,
      yMin: box['yMin'] as double,
      xMax: box['xMax'] as double,
      yMax: box['yMax'] as double,
    );

    bool isBlurry = false;

    final cropResult = FaceCropHelper.cropFaceRoi(
      inputImage,
      box,
      kps,
      ldH,
      ldW,
      scale: 1.1,
    );

    final iqaPatch = cropResult.patch;

    final brightness = BrightnessChecker.check(iqaPatch);
    final isTooBright = BrightnessChecker.isTooBright(brightness);
    final isTooDark = BrightnessChecker.isTooDark(brightness);

    final iqaInput = IQAPreprocessor.preprocess(iqaPatch);
    final iqaOutput = List.filled(1, List.filled(1, 0.0));
    _iqa.run(iqaInput.reshape([1, 224, 224, 3]), iqaOutput);

    if (iqaOutput[0][0] > 0.55) {
      _blurryFrames++;
    } else {
      _blurryFrames = 0;
    }

    isBlurry = _blurryFrames >= 4;

    final visibleImgH = inputImage.height * (1.0 - cropRatio);
    final cropOffset = inputImage.height * cropRatio;

    final chinVisible = FaceLandmarksPostprocessor.isChinVisible(
      lmOrig,
      inputImage.width.toDouble(),
      visibleImgH,
      box,
    );

    final foreheadVisible = FaceLandmarksPostprocessor.isForeheadVisible(
      lmOrig,
      inputImage.width.toDouble(),
      visibleImgH,
      cropOffset,
    );

    return FaceAnalysisResult(
      detectionScore: bestFace['score'] as double,
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
    );
  }

  void dispose() {
    _faceDetector.close();
    _faceLandmarks.close();
    _iqa.close();
  }
}
