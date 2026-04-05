enum AvatarDetectionStatus {
  ok,
  tooHigh,
  tooLow,
  tooFar,
  closedEyes,
  notVisible,
  lookStraight,
  tooBright,
  tooDark;

  String get text {
    switch (this) {
      case AvatarDetectionStatus.ok:
        return 'Click the button to take a photo.';
      case AvatarDetectionStatus.tooHigh:
        return 'Tilt your face downward.';
      case AvatarDetectionStatus.tooLow:
        return 'Tilt your face upward.';
      case AvatarDetectionStatus.notVisible:
        return 'Face is not visible. Please center your face in the frame.';
      case AvatarDetectionStatus.tooFar:
        return 'Face is too far. Move closer to the camera.';
      case AvatarDetectionStatus.closedEyes:
        return 'Your eyes are closed. Please make sure they are open.';
      case AvatarDetectionStatus.lookStraight:
        return 'Please look straight at the camera.';
      case AvatarDetectionStatus.tooBright:
        return 'The image is too bright.';
      case AvatarDetectionStatus.tooDark:
        return 'The image is too dark.';
    }
  }

  String? get image {
    switch (this) {
      case AvatarDetectionStatus.tooHigh:
        return null;
      case AvatarDetectionStatus.tooLow:
        return 'packages/dataspikemobilesdk/assets/images/down_arrow.svg';
      default:
        return null;
    }
  }
}
