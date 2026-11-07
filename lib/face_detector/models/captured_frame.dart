import 'dart:typed_data';

/// A single captured (shutter) frame's pixel data — already converted to
/// RGBA and correctly oriented (rotated on Android, as-is on iOS), but
/// deliberately *not* JPEG-encoded yet.
///
/// Encoding is deferred until after cropping (see
/// `processAvatarShotInIsolate`), so each frame goes through exactly one
/// JPEG encode instead of encode -> decode -> crop -> encode.
class CapturedFrame {
  final Uint8List rgbaBytes;
  final int width;
  final int height;

  const CapturedFrame({
    required this.rgbaBytes,
    required this.width,
    required this.height,
  });
}
