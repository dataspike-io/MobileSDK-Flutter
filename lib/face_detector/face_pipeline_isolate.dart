import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';

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
      final image = img.Image.fromBytes(
        width: request['width'] as int,
        height: request['height'] as int,
        bytes: (request['bytes'] as Uint8List).buffer,
        order: img.ChannelOrder.rgb,
      );

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
    img.Image image, {
    double cropRatio = 0.0,
  }) async {
    final replyPort = ReceivePort();

    _toIsolate.send({
      'bytes': Uint8List.fromList(image.getBytes(order: img.ChannelOrder.rgb)),
      'width': image.width,
      'height': image.height,
      'cropRatio': cropRatio,
      'replyPort': replyPort.sendPort,
    });

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
