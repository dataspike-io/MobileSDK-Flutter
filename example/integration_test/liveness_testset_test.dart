// Runs the on-device face pipeline over the ML team's labelled selfie test
// set (one folder per expected error) and prints raw metrics per image.
//
// Images are analyzed whole, without the avatar-mask crop: the set consists
// of already-uploaded photos and the server checks them as-is.
//
// flutter test integration_test/liveness_testset_test.dart -d <simulator> \
//   --dart-define=TESTSET_DIR=/abs/path/to/assets/images/test

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';

import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';

const _testSetDir = String.fromEnvironment('TESTSET_DIR');
const _imageExts = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'};

Future<Uint8List> _asset(String name) async =>
    (await rootBundle.load('packages/dataspikemobilesdk/assets/ml/$name'))
        .buffer
        .asUint8List();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('liveness test set', (tester) async {
    expect(_testSetDir, isNotEmpty, reason: 'pass --dart-define=TESTSET_DIR');

    final pipeline = await FacePipeline.createFromBytes(
      detectorBytes: await _asset('face_detector.tflite'),
      landmarksBytes: await _asset('face_landmarks_detector.tflite'),
      canonicalData: await rootBundle.loadString(
        'packages/dataspikemobilesdk/assets/ml/canonical_face_model.obj',
      ),
      iqaBytes: await _asset('iqa_mobilenetv3small100_sigmoid.tflite'),
    );

    final categories =
        Directory(_testSetDir).listSync().whereType<Directory>().toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final category in categories) {
      final files =
          category
              .listSync()
              .whereType<File>()
              .where((f) {
                final name = f.path.toLowerCase();
                return _imageExts.any(name.endsWith);
              })
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final record = <String, dynamic>{
          'category': category.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
          'file': file.uri.pathSegments.last,
        };

        final decoded = img.decodeImage(file.readAsBytesSync());
        if (decoded == null) {
          record['error'] = 'decode_failed';
        } else {
          // cv2.imread applies EXIF orientation, so the reference does too.
          final image = img.bakeOrientation(decoded);
          record['w'] = image.width;
          record['h'] = image.height;

          pipeline.resetState();
          final r = await pipeline.analyze(image);
          if (r == null) {
            record['error'] = 'no_face';
          } else {
            final b = r.boundingBox;
            record.addAll({
              'det': r.detectionScore,
              'pitch': r.headPose?['pitch'],
              'yaw': r.headPose?['yaw'],
              'roll': r.headPose?['roll'],
              'poseOk': r.isHeadPoseAcceptable,
              'earL': r.leftEar,
              'earR': r.rightEar,
              'blur': r.blurScore,
              'bright': r.brightRatio,
              'dark': r.darkRatio,
              'chin': r.isChinVisible,
              'forehead': r.isForeheadVisible,
              'faceArea': b.width * b.height / (image.width * image.height),
            });
          }
        }

        // ignore: avoid_print
        print('TESTSET_RESULT ${jsonEncode(record)}');
      }
    }

    pipeline.dispose();
  }, timeout: const Timeout(Duration(minutes: 30)));
}
