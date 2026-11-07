// Times the face pipeline on a synthetic Android-like camera frame
// (1280x720 landscape YUV_420_888, uvPixelStride 2), following the same path
// as the live camera: YUV -> RGB + rotate, avatar-mask crop, three models.
//
// flutter test integration_test/liveness_benchmark_test.dart -d <device>

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';

import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/camera_frame_conversion.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

const _sensorW = 1280;
const _sensorH = 720;
const _step = 2;
const _warmup = 3;
const _runs = 10;

Future<Uint8List> _asset(String path) async =>
    (await rootBundle.load('packages/dataspikemobilesdk/$path')).buffer
        .asUint8List();

// Portrait face picture -> landscape sensor frame encoded as YUV_420_888.
Future<CameraFrameInput> _syntheticFrame() async {
  final face = img.decodeImage(
    await _asset('assets/images/liveness_instruction_1.png'),
  )!;
  final portrait = img.copyResize(face, width: _sensorH, height: _sensorW);
  final sensor = img.copyRotate(portrait, angle: 90);

  final y = Uint8List(_sensorW * _sensorH);
  final u = Uint8List(_sensorW * _sensorH ~/ 2);
  final v = Uint8List(_sensorW * _sensorH ~/ 2);
  for (int yy = 0; yy < _sensorH; yy++) {
    for (int xx = 0; xx < _sensorW; xx++) {
      final p = sensor.getPixel(xx, yy);
      final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
      y[yy * _sensorW + xx] = (0.299 * r + 0.587 * g + 0.114 * b)
          .round()
          .clamp(0, 255);
      if (yy.isEven && xx.isEven) {
        final i = (yy ~/ 2) * _sensorW + (xx ~/ 2) * 2;
        u[i] = (-0.168736 * r - 0.331264 * g + 0.5 * b + 128).round().clamp(
          0,
          255,
        );
        v[i] = (0.5 * r - 0.418688 * g - 0.081312 * b + 128).round().clamp(
          0,
          255,
        );
      }
    }
  }

  return CameraFrameInput.yuv420Rotated90(
    yPlane: y,
    uPlane: u,
    vPlane: v,
    sensorWidth: _sensorW,
    sensorHeight: _sensorH,
    yRowStride: _sensorW,
    uvRowStride: _sensorW,
    uvPixelStride: 2,
    step: _step,
  );
}

String _ms(List<double> xs) {
  xs.sort();
  final avg = xs.reduce((a, b) => a + b) / xs.length;
  return 'avg ${avg.toStringAsFixed(1)} ms, median '
      '${xs[xs.length ~/ 2].toStringAsFixed(1)} ms';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pipeline timing', (tester) async {
    final frame = await _syntheticFrame();
    // Typical phone container: full width, 80% of the screen height.
    final rect = avatarCropRect(
      imageWidth: frame.width,
      imageHeight: frame.height,
      containerW: 411,
      containerH: 676,
      previewW: _sensorW.toDouble(),
      previewH: _sensorH.toDouble(),
      sideInsetPct: CameraConstants.avatarSideInsetPct,
      topApexPct: CameraConstants.avatarTopApexPct,
      bottomApexFromBottomPct: CameraConstants.avatarBottomApexFromBottomPct,
      strokeWidth: CameraConstants.avatarStrokeWidth,
    );

    // 1) End to end through the real isolate, as the camera screen calls it.
    final iso = await FacePipelineIsolate.create();
    final total = <double>[];
    for (int i = 0; i < _warmup + _runs; i++) {
      final sw = Stopwatch()..start();
      final r = await iso.analyze(frame, avatarRect: rect);
      sw.stop();
      expect(r, isNotNull, reason: 'face must be found in the test frame');
      if (i >= _warmup) total.add(sw.elapsedMicroseconds / 1000);
    }
    iso.dispose();
    // ignore: avoid_print
    print('BENCH end-to-end (isolate): ${_ms(total)}');

    // 2) Per-stage breakdown in this isolate.
    final pipeline = await FacePipeline.createFromBytes(
      detectorBytes: await _asset('assets/ml/face_detector.tflite'),
      landmarksBytes: await _asset('assets/ml/face_landmarks_detector.tflite'),
      canonicalData: await rootBundle.loadString(
        'packages/dataspikemobilesdk/assets/ml/canonical_face_model.obj',
      ),
      iqaBytes: await _asset('assets/ml/iqa_mobilenetv3small100_sigmoid.tflite'),
    );
    final stages = <String, List<double>>{};
    for (int i = 0; i < _warmup + _runs; i++) {
      final sw = Stopwatch()..start();
      final rgbFrame = yuv420ToRgbFrame(
        yPlane: frame.yPlane!,
        uPlane: frame.uPlane!,
        vPlane: frame.vPlane!,
        sensorWidth: frame.sensorWidth,
        sensorHeight: frame.sensorHeight,
        yRowStride: frame.yRowStride,
        uvRowStride: frame.uvRowStride,
        uvPixelStride: frame.uvPixelStride,
        step: frame.step,
      );
      final convertMs = sw.elapsedMicroseconds / 1000;
      await pipeline.analyzeFrame(rgbFrame, avatarRect: rect);
      if (i < _warmup) continue;
      stages.putIfAbsent('yuv->rgb', () => []).add(convertMs);
      pipeline.lastTimingsMs.forEach(
        (k, v) => stages.putIfAbsent(k, () => []).add(v),
      );
    }
    pipeline.dispose();
    for (final e in stages.entries) {
      // ignore: avoid_print
      print('BENCH ${e.key.padRight(16)} ${_ms(e.value)}');
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
