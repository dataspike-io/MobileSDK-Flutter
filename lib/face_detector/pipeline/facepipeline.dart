import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/postprocessing/face_detector_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_detector/preprocessing/face_detector_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/face_landmarks_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/preprocessing/face_landmarks_preprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/head_pose_estimator.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_crop/face_crop_helper.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';

class FacePipeline {
  late Interpreter _faceDetector;
  late Interpreter _faceLandmarks;

  late final List<List<List<double>>> _boxCoords1;
  late final List<List<List<double>>> _boxCoords2;
  late final List<List<List<double>>> _boxScores1;
  late final List<List<List<double>>> _boxScores2;
  late final List<List<List<double>>> _landmarksTensor;
  late final List<double> _scoresTensor;

  List<List<double>> _canonical = [];

  // Initialize all models
  static Future<FacePipeline> create() async {
    final pipeline = FacePipeline();

    pipeline._faceDetector = await Interpreter.fromAsset(
      'packages/dataspikemobilesdk/assets/ml/mediapipe_face-facedetector-float.tflite',
    );
    pipeline._faceLandmarks = await Interpreter.fromAsset(
      'packages/dataspikemobilesdk/assets/ml/mediapipe_face-facelandmarkdetector-float.tflite',
    );

    pipeline._canonical = await _loadCanonical();

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

  static Future<List<List<double>>> _loadCanonical() async {
    final data = await rootBundle.loadString(
      'packages/dataspikemobilesdk/assets/ml/canonical_face_model.obj',
    );
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
    assert(verts.length == 468);
    return verts;
  }

  Future<FaceAnalysisResult?> analyze(img.Image inputImage) async {
    final detectorInput = FaceDetectorPreprocessor.preprocess(inputImage);

    _faceDetector.runForMultipleInputs(
      [
        detectorInput.reshape([1, 256, 256, 3]),
      ],
      {0: _boxCoords1, 1: _boxCoords2, 2: _boxScores1, 3: _boxScores2},
    );

    final origH = inputImage.height;
    final origW = inputImage.width;
    final scale = math.min(256 / origH, 256 / origW);

    final detectedFaces = FaceDetectorPostprocessor.postprocess(
      _boxCoords1,
      _boxCoords2,
      _boxScores1,
      _boxScores2,
      scale,
    );

    if (detectedFaces.isEmpty) return null;

    final bestFace = detectedFaces.first;
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

    return FaceAnalysisResult(
      detectionScore: bestFace['score'] as double,
      landmarks: landmarks,
      headPose: headPose,
      isHeadPoseAcceptable: isHeadPoseOk,
      eyeStatus: eyeStatus,
      boundingBox: absoluteBox,
    );
  }

  void dispose() {
    _faceDetector.close();
    _faceLandmarks.close();
  }
}
