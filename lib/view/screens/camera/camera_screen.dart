import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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
  CameraDescription? _backCam;
  CameraDescription? _frontCam;
  bool _useFront = false;

  @override
  void initState() {
    super.initState();
    _init = _setup();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.back && _backCam == null) {
        _backCam = c;
      }
      if (c.lensDirection == CameraLensDirection.front && _frontCam == null) {
        _frontCam = c;
      }
    }
    final initial = _backCam ?? _frontCam ?? cams.first;
    _ctrl = CameraController(
      initial,
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

    await Permission.photos.request();

    final file = await _ctrl!.takePicture();
    final bytes = await file.readAsBytes();

    img.Image? original = img.decodeImage(bytes);
    if (original == null) return;

    // 1) Учитываем EXIF — иначе кроп «съедет»
    original = img.bakeOrientation(original);

    final imgW = original.width.toDouble();
    final imgH = original.height.toDouble();

    // 2) Размер контейнера превью
    final rb = previewKey.currentContext!.findRenderObject() as RenderBox;
    final containerW = rb.size.width;
    final containerH = rb.size.height;

    // 3) Те же параметры, что в build()
    final ps = _ctrl!.value.previewSize!;
    final previewAR = ps.height / ps.width; // width/height (портрет)
    final containerAR = containerW / containerH;
    final coverScale = previewAR / containerAR; // как в Transform.scale

    // 4) Базовый "fit" размер дочернего AspectRatio до масштабирования
    double childW, childH;
    if (containerAR > previewAR) {
      // контейнер шире, чем превью — вписываем по высоте
      childH = containerH;
      childW = childH * previewAR;
    } else {
      // контейнер уже — вписываем по ширине
      childW = containerW;
      childH = childW / previewAR;
    }

    // 5) Итоговый размер показанного кадра с учетом coverScale
    final displayW = childW * coverScale;
    final displayH = childH * coverScale;

    // 6) Смещения (обрезка по краям из-за cover)
    final offsetX = (containerW - displayW) / 2.0;
    final offsetY = (containerH - displayH) / 2.0;

    // 7) Те же размеры рамки, что в UI
    final screenSize = MediaQuery.of(context).size;
    final cropW = screenSize.width * 0.85;
    final cropH = screenSize.height * 0.3;
    final cropLeftInWidget = (containerW - cropW) / 2.0;
    final cropTopInWidget = (containerH - cropH) / 2.0;

    // 8) Масштаб от изображения к показу (единичный в обеих осях)
    final scale = displayW / imgW; // = displayH / imgH при корректном AR

    int x = (((cropLeftInWidget - offsetX) / scale).round()).clamp(
      0,
      imgW.toInt() - 1,
    );
    int y = (((cropTopInWidget - offsetY) / scale).round()).clamp(
      0,
      imgH.toInt() - 1,
    );
    int w = ((cropW / scale).round()).clamp(1, imgW.toInt() - x);
    int h = ((cropH / scale).round()).clamp(1, imgH.toInt() - y);

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
    final out = img.encodeJpg(cropped, quality: 100);

    await ImageGallerySaver.saveImage(Uint8List.fromList(out));
    widget.onCropped(Uint8List.fromList(out));
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final Uint8List raw = await picked.readAsBytes();

      widget.onCropped(raw);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    }
  }

  Future<void> _toggleCamera() async {
    if (_frontCam == null && _backCam == null) return;
    final newDesc = _useFront ? (_backCam ?? _ctrl!.description) : (_frontCam ?? _ctrl!.description);
    if (newDesc == _ctrl!.description) return; // nothing to change
    _useFront = !_useFront;
    await _ctrl?.dispose();
    _ctrl = CameraController(
      newDesc,
      ResolutionPreset.max,
      enableAudio: false,
    );
    try {
      await _ctrl!.initialize();
      await _ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final cropWidth = screenSize.width * 0.85;
    final cropHeight = screenSize.height * 0.3;

    final camWidth = screenSize.width - 10;
    final camHeight = screenSize.height * 0.65;

    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 128),

              Center(
                child: SizedBox(
                  key: previewKey,
                  width: camWidth,
                  height: camHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final ps = _ctrl!.value.previewSize!;
                        final previewAR = ps.height / ps.width; // width/height
                        final containerAR = c.maxWidth / c.maxHeight;
                        final coverScale = previewAR / containerAR; // >= 1

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.scale(
                              scale: coverScale,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: previewAR,
                                  child: CameraPreview(_ctrl!),
                                ),
                              ),
                            ),

                            // Димминг всего кроме окна
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DimOverlayPainter(
                                  holeRect: Rect.fromCenter(
                                    center: Offset(c.maxWidth / 2, c.maxHeight / 2),
                                    width: cropWidth,
                                    height: cropHeight,
                                  ),
                                ),
                              ),
                            ),
                            // Рамка (углы) поверх затемнения
                            Center(
                              child: CustomPaint(
                                size: Size(cropWidth, cropHeight),
                                painter: GreyCornersPainter(
                                  rect: Rect.fromLTWH(0, 0, cropWidth, cropHeight),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 16,
                              child: (_frontCam != null || _backCam != null)
                                  ? Builder(
                                      builder: (context) {
                                        final canSwitch = _frontCam != null && _backCam != null;
                                        return Opacity(
                                          opacity: canSwitch ? 1 : 0.4,
                                          child: Material(
                                            color: Colors.black45,
                                            shape: const CircleBorder(),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.cameraswitch,
                                                color: Colors.white,
                                              ),
                                              onPressed: canSwitch ? _toggleCamera : null,
                                              tooltip: _useFront
                                                  ? 'Switch to back camera'
                                                  : 'Switch to front camera',
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Positioned(
                              top: 100,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text('Please make a photo of front-side of ID',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
                                  textAlign: TextAlign.center,)
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () => _shootAndCrop(previewKey),
                    child: Text(
                      'Take a photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextButton(
                    onPressed: _pickAndUploadDocument,
                    child: Text(
                      'Upload document',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DimOverlayPainter extends CustomPainter {
  final Rect holeRect;
  final double borderRadius;
  final Color overlayColor;

  DimOverlayPainter({
    required this.holeRect,
    this.borderRadius = 20,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.55),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectXY(holeRect, borderRadius, borderRadius));
    path.fillType = PathFillType.evenOdd; // вырезаем отверстие
    final paint = Paint()..color = overlayColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GreyCornersPainter extends CustomPainter {
  final Rect rect;

  GreyCornersPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerLen = 40.0;
    final radius = 20.0;
    final stroke = 5.0;
    final color = Colors.grey.shade400;

    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      switch (i) {
        case 0:
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.lineTo(corners[i].dx + cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy + radius);
          path.lineTo(corners[i].dx, corners[i].dy + cornerLen);
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy + radius),
            radius: Radius.circular(radius),
            clockwise: false,
          );
          break;
        case 1:
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.lineTo(corners[i].dx - cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy + radius);
          path.lineTo(corners[i].dx, corners[i].dy + cornerLen);
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy + radius),
            radius: Radius.circular(radius),
            clockwise: true,
          );
          break;
        case 2:
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.lineTo(corners[i].dx - cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy - radius);
          path.lineTo(corners[i].dx, corners[i].dy - cornerLen);
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy - radius),
            radius: Radius.circular(radius),
            clockwise: false,
          );
          break;
        case 3:
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.lineTo(corners[i].dx + cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy - radius);
          path.lineTo(corners[i].dx, corners[i].dy - cornerLen);
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy - radius),
            radius: Radius.circular(radius),
            clockwise: true,
          );
          break;
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
