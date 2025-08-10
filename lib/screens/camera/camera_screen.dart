import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class LiveCropCamera extends StatefulWidget {
  final Size cropBox;                 
  final ValueChanged<Uint8List> onCropped; 

  const LiveCropCamera({
    super.key,
    required this.cropBox,
    required this.onCropped,
  });

  @override
  State<LiveCropCamera> createState() => _LiveCropCameraState();
}

class _LiveCropCameraState extends State<LiveCropCamera> {
  CameraController? _ctrl;
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _setup();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    _ctrl = CameraController(
      cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cams.first),
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _ctrl!.initialize();
    await _ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _shootAndCrop(GlobalKey previewKey) async {
    if (!(_ctrl?.value.isInitialized ?? false)) return;

    final file = await _ctrl!.takePicture();
    final bytes = await file.readAsBytes();

    img.Image? original = img.decodeImage(bytes);
    if (original == null) return;

    int imgW = original.width;
    int imgH = original.height;

    final renderBox = previewKey.currentContext!.findRenderObject() as RenderBox;
    final previewSize = renderBox.size; 
    final camAspect = _ctrl!.value.previewSize!.height / _ctrl!.value.previewSize!.width; 

    final widgetAR = previewSize.width / previewSize.height;
    final imageAR  = 1 / camAspect;

    double shownW, shownH;
    if (widgetAR > imageAR) {
      shownW = previewSize.width;
      shownH = previewSize.width / imageAR;
    } else {
      shownH = previewSize.height;
      shownW = previewSize.height * imageAR;
    }

    final cropW = widget.cropBox.width;
    final cropH = widget.cropBox.height;
    final cropLeftInWidget = (previewSize.width - cropW) / 2;
    final cropTopInWidget  = (previewSize.height - cropH) / 2;

    final offsetX = (previewSize.width - shownW) / 2;
    final offsetY = (previewSize.height - shownH) / 2;

    final fracLeft = (cropLeftInWidget - offsetX) / shownW;
    final fracTop  = (cropTopInWidget - offsetY) / shownH;
    final fracW    = cropW / shownW;
    final fracH    = cropH / shownH;

    int x = (fracLeft * imgW).clamp(0, imgW - 1).toInt();
    int y = (fracTop  * imgH).clamp(0, imgH - 1).toInt();
    int w = (fracW    * imgW).clamp(1, imgW - x).toInt();
    int h = (fracH    * imgH).clamp(1, imgH - y).toInt();

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
    final out = img.encodeJpg(cropped, quality: 95);

    widget.onCropped(Uint8List.fromList(out));
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();

    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final cropSize = widget.cropBox;

        return Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _ctrl!.value.aspectRatio,
              child: Container(
                key: previewKey,
                color: Colors.black,
                child: CameraPreview(_ctrl!),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _OverlayMaskPainter(
                  box: cropSize,
                  borderColor: Colors.white,
                ),
              ),
            ),

            Positioned(
              bottom: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _shootAndCrop(previewKey),
                child: const Text('Capture'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayMaskPainter extends CustomPainter {
  final Size box;
  final Color borderColor;

  _OverlayMaskPainter({required this.box, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final r = Rect.fromLTWH(
      (size.width - box.width) / 2,
      (size.height - box.height) / 2,
      box.width,
      box.height,
    );
    final hole = Path()..addRRect(RRect.fromRectXY(r, 12, 12));
    final mask = Path.combine(PathOperation.difference, overlay, hole);

    canvas.drawPath(mask, Paint()..color = Colors.black.withOpacity(0.5));
    canvas.drawRRect(
      RRect.fromRectXY(r, 12, 12),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayMaskPainter oldDelegate) =>
      oldDelegate.box != box || oldDelegate.borderColor != borderColor;
}

