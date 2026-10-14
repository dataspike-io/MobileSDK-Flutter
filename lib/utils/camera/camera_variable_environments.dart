class CameraConstants {
  const CameraConstants._();

  static const double avatarStrokeWidth = 3.0;
  static const double avatarSideInsetPct = 0.15;
  static const double avatarTopApexPct = 0.2;
  static const double avatarBottomApexFromBottomPct = 0.25;

  /// Face box must cover at least this share of the avatar crop.
  static const double minFaceAreaFraction = 0.1;

  /// Whether the uploaded liveness photos are cropped to the avatar mask.
  /// When false the full camera frame is uploaded; the live on-device
  /// checks still look at the mask area either way.
  static const bool cropLivenessPhotosToMask = false;
}