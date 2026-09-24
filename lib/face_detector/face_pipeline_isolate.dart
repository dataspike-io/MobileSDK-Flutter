import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';

/// Converts a raw YUV420 camera frame to RGB and rotates it -90°
/// (portrait), mirroring what the Android camera preview needs. Runs
/// inside the pipeline isolate so this per-pixel work never blocks the
/// UI isolate.
img.Image _convertYuv420ToImage({
  required Uint8List yPlane,
  required Uint8List uPlane,
  required Uint8List vPlane,
  required int sensorWidth,
  required int sensorHeight,
  required int yRowStride,
  required int uvRowStride,
  required int uvPixelStride,
  required int step,
}) {
  final dstW = sensorWidth ~/ step;
  final dstH = sensorHeight ~/ step;

  final rgba = Uint8List(dstW * dstH * 4);
  for (int dy = 0; dy < dstH; dy++) {
    final sy = dy * step;
    for (int dx = 0; dx < dstW; dx++) {
      final sx = dx * step;
      final yValue = yPlane[sy * yRowStride + sx] & 0xFF;
      final uvIndex = (sy ~/ 2) * uvRowStride + (sx ~/ 2) * uvPixelStride;
      final u = (uPlane[uvIndex] & 0xFF) - 128;
      final v = (vPlane[uvIndex] & 0xFF) - 128;
      final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
      final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
      final b = (yValue + 1.772 * u).clamp(0, 255).toInt();
      final idx = (dy * dstW + dx) * 4;
      rgba[idx] = r;
      rgba[idx + 1] = g;
      rgba[idx + 2] = b;
      rgba[idx + 3] = 255;
    }
  }

  final rgbImage = img.Image.fromBytes(
    width: dstW,
    height: dstH,
    bytes: rgba.buffer,
    order: img.ChannelOrder.rgba,
  );
  return img.copyRotate(rgbImage, angle: -90);
}

/// Downsamples raw BGRA camera bytes into an RGB image. No rotation: iOS
/// delivers already portrait-oriented frames. Runs inside the pipeline
/// isolate, mirroring the YUV420 path above.
img.Image _convertBgraToImage({
  required Uint8List bgraBytes,
  required int sensorWidth,
  required int sensorHeight,
  required int bgraRowStride,
  required int step,
}) {
  final dstW = sensorWidth ~/ step;
  final dstH = sensorHeight ~/ step;

  final out = Uint8List(dstW * dstH * 4);
  for (int dy = 0; dy < dstH; dy++) {
    final srcRowOffset = (dy * step) * bgraRowStride;
    for (int dx = 0; dx < dstW; dx++) {
      final srcIdx = srcRowOffset + (dx * step) * 4;
      final dstIdx = (dy * dstW + dx) * 4;
      out[dstIdx] = bgraBytes[srcIdx];
      out[dstIdx + 1] = bgraBytes[srcIdx + 1];
      out[dstIdx + 2] = bgraBytes[srcIdx + 2];
      out[dstIdx + 3] = bgraBytes[srcIdx + 3];
    }
  }

  return img.Image.fromBytes(
    width: dstW,
    height: dstH,
    bytes: out.buffer,
    order: img.ChannelOrder.bgra,
  );
}

class _IsolateInitData {
  final SendPort toMain;
  final Uint8List detectorBytes;
  final Uint8List landmarksBytes;
  final String canonicalData;
  final Uint8List iqaBytes;

  _IsolateInitData({
    required this.toMain,
    required this.detectorBytes,
    required this.landmarksBytes,
    required this.canonicalData,
    required this.iqaBytes,
  });
}

void _isolateEntry(_IsolateInitData init) async {
  final fromMain = ReceivePort();
  init.toMain.send(fromMain.sendPort);

  FacePipeline? pipeline;
  try {
    pipeline = await FacePipeline.createFromBytes(
      detectorBytes: init.detectorBytes,
      landmarksBytes: init.landmarksBytes,
      canonicalData: init.canonicalData,
      iqaBytes: init.iqaBytes,
    );
  } catch (e) {
    init.toMain.send({'initError': e.toString()});
    fromMain.close();
    return;
  }

  await for (final msg in fromMain) {
    if (msg == 'dispose') {
      pipeline.dispose();
      fromMain.close();
      return;
    }

    final request = msg as Map<String, dynamic>;
    final replyPort = request['replyPort'] as SendPort;

    if (request.containsKey('reset')) {
      pipeline.resetState();
      request['replyPort'].send(null);
      continue;
    }

    try {
      final img.Image image;
      if (request.containsKey('yPlane')) {
        image = _convertYuv420ToImage(
          yPlane: request['yPlane'] as Uint8List,
          uPlane: request['uPlane'] as Uint8List,
          vPlane: request['vPlane'] as Uint8List,
          sensorWidth: request['sensorWidth'] as int,
          sensorHeight: request['sensorHeight'] as int,
          yRowStride: request['yRowStride'] as int,
          uvRowStride: request['uvRowStride'] as int,
          uvPixelStride: request['uvPixelStride'] as int,
          step: request['step'] as int,
        );
      } else if (request.containsKey('bgraBytes')) {
        image = _convertBgraToImage(
          bgraBytes: request['bgraBytes'] as Uint8List,
          sensorWidth: request['sensorWidth'] as int,
          sensorHeight: request['sensorHeight'] as int,
          bgraRowStride: request['bgraRowStride'] as int,
          step: request['step'] as int,
        );
      } else {
        image = img.Image.fromBytes(
          width: request['width'] as int,
          height: request['height'] as int,
          bytes: (request['bytes'] as Uint8List).buffer,
          order: img.ChannelOrder.rgb,
        );
      }

      final cropRatio = request['cropRatio'] as double? ?? 0.0;
      final result = await pipeline.analyze(image, cropRatio: cropRatio);
      
      if (result == null) {
        replyPort.send(null);
        continue;
      }

      replyPort.send({
        'detectionScore': result.detectionScore,
        'landmarks': result.landmarks,
        'headPose': result.headPose,
        'isHeadPoseAcceptable': result.isHeadPoseAcceptable,
        'eyeStatus': result.eyeStatus,
        'xMin': result.boundingBox.xMin,
        'yMin': result.boundingBox.yMin,
        'xMax': result.boundingBox.xMax,
        'yMax': result.boundingBox.yMax,
        'isBlurry': result.isBlurry,
        'isChinVisible': result.isChinVisible,
        'isForeheadVisible': result.isForeheadVisible,
        'isTooBright': result.isTooBright,
        'isTooDark': result.isTooDark,
      });
    } catch (e) {
      replyPort.send({'error': e.toString()});
    }
  }
}

class FacePipelineIsolate {
  late final SendPort _toIsolate;
  late final Isolate _isolate;

  Future<void> resetState() async {
    final replyPort = ReceivePort();
    _toIsolate.send({'reset': true, 'replyPort': replyPort.sendPort});
    await replyPort.first;
    replyPort.close();
  }

  static Future<FacePipelineIsolate> create() async {
    final iqaBytes = await rootBundle.load(
      'packages/dataspikemobilesdk/assets/ml/iqa_mobilenetv3small100_sigmoid.tflite',
    );
    final detectorBytes = await rootBundle.load(
      'packages/dataspikemobilesdk/assets/ml/mediapipe_face-facedetector-float.tflite',
    );
    final landmarksBytes = await rootBundle.load(
      'packages/dataspikemobilesdk/assets/ml/mediapipe_face-facelandmarkdetector-float.tflite',
    );
    final canonicalData = await rootBundle.loadString(
      'packages/dataspikemobilesdk/assets/ml/canonical_face_model.obj',
    );

    final instance = FacePipelineIsolate();
    final fromIsolate = ReceivePort();

    instance._isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolateInitData(
        toMain: fromIsolate.sendPort,
        detectorBytes: detectorBytes.buffer.asUint8List(),
        landmarksBytes: landmarksBytes.buffer.asUint8List(),
        canonicalData: canonicalData,
        iqaBytes: iqaBytes.buffer.asUint8List(),
      ),
    );

    final first = await fromIsolate.first;
    if (first is Map && first.containsKey('initError')) {
      throw Exception('Pipeline isolate init failed: ${first['initError']}');
    }

    instance._toIsolate = first as SendPort;
    fromIsolate.close();
    return instance;
  }

  Future<FaceAnalysisResult?> analyze(
    CameraFrameInput frame, {
    double cropRatio = 0.0,
  }) async {
    final replyPort = ReceivePort();

    final Map<String, dynamic> message = {
      'cropRatio': cropRatio,
      'replyPort': replyPort.sendPort,
    };

    final decoded = frame.decoded;
    final bgraBytes = frame.bgraBytes;
    if (decoded != null) {
      message['bytes'] = Uint8List.fromList(
        decoded.getBytes(order: img.ChannelOrder.rgb),
      );
      message['width'] = decoded.width;
      message['height'] = decoded.height;
    } else if (bgraBytes != null) {
      message['bgraBytes'] = bgraBytes;
      message['sensorWidth'] = frame.sensorWidth;
      message['sensorHeight'] = frame.sensorHeight;
      message['bgraRowStride'] = frame.bgraRowStride;
      message['step'] = frame.step;
    } else {
      message['yPlane'] = frame.yPlane;
      message['uPlane'] = frame.uPlane;
      message['vPlane'] = frame.vPlane;
      message['sensorWidth'] = frame.sensorWidth;
      message['sensorHeight'] = frame.sensorHeight;
      message['yRowStride'] = frame.yRowStride;
      message['uvRowStride'] = frame.uvRowStride;
      message['uvPixelStride'] = frame.uvPixelStride;
      message['step'] = frame.step;
    }

    _toIsolate.send(message);

    final response = await replyPort.first;
    replyPort.close();

    if (response == null) return null;

    final map = response as Map<String, dynamic>;
    if (map.containsKey('error')) throw Exception(map['error']);

    return FaceAnalysisResult(
      detectionScore: map['detectionScore'] as double,
      landmarks: (map['landmarks'] as List).cast<Map<String, double>>(),
      headPose: map['headPose'] as Map<String, double>?,
      isHeadPoseAcceptable: map['isHeadPoseAcceptable'] as bool,
      eyeStatus: (map['eyeStatus'] as Map).cast<String, bool>(),
      boundingBox: FaceBoundingBox(
        xMin: map['xMin'] as double,
        yMin: map['yMin'] as double,
        xMax: map['xMax'] as double,
        yMax: map['yMax'] as double,
      ),
      isBlurry: map['isBlurry'] as bool,
      isChinVisible: map['isChinVisible'] as bool,
      isForeheadVisible: map['isForeheadVisible'] as bool,
      isTooBright: map['isTooBright'] as bool,
      isTooDark: map['isTooDark'] as bool,
    );
  }

  void dispose() {
    _toIsolate.send('dispose');
    _isolate.kill();
  }
}
