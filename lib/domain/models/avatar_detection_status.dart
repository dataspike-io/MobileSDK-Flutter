import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

enum AvatarDetectionStatus {
  ok,
  tooHigh,
  tooLow,
  tooFar,
  closedEyes,
  notVisible,
  lookStraight,
  tooBright,
  tooDark,
  lowQuality,
  chinIsNotVisible,
  foreheadisNotVidible,

  undetected,
  notStarted,

  success,

  // ExternalErrors
  headwearIsOn,
  halfAttempts;

  String get title {
    switch (this) {
      case AvatarDetectionStatus.ok:
        return 'Hold on!';
      case AvatarDetectionStatus.tooHigh:
        return 'Tilt your face downward.';
      case AvatarDetectionStatus.tooLow:
        return 'Tilt your face upward.';
      case AvatarDetectionStatus.notVisible:
        return 'Face is not entire inside mask ';
      case AvatarDetectionStatus.tooFar:
        return 'Move your face closer';
      case AvatarDetectionStatus.closedEyes:
        return 'We could not detect your eyes.';
      case AvatarDetectionStatus.lookStraight:
        return 'Your face is not fully in the frame.';
      case AvatarDetectionStatus.tooBright:
        return 'Too bright.';
      case AvatarDetectionStatus.tooDark:
        return 'Too dark.';
      case AvatarDetectionStatus.lowQuality:
        return 'Image quality is insufficient.';
      case AvatarDetectionStatus.success:
        return 'Great. Check completed';
      case AvatarDetectionStatus.chinIsNotVisible:
        return 'Chin is not visible';
      case AvatarDetectionStatus.foreheadisNotVidible:
        return 'Forehead is not visible';
      case AvatarDetectionStatus.halfAttempts:
        return 'You wasted half your attempts';
      case AvatarDetectionStatus.headwearIsOn:
        return 'Headwear or glasses detected.';
      case AvatarDetectionStatus.undetected:
      case AvatarDetectionStatus.notStarted:
        return '';
    }
  }

  bool get isVisible {
    switch (this) {
      case AvatarDetectionStatus.notStarted:
      case AvatarDetectionStatus.undetected:
        return false;
      default:
        return true;
    }
  }

  bool get isScaled {
    switch (this) {
      case AvatarDetectionStatus.notStarted:
        return false;
      default:
        return true;
    }
  }

  Color get arcColor {
    switch (this) {
      case AvatarDetectionStatus.tooHigh:
      case AvatarDetectionStatus.tooLow:
        return AppColors.lightRed;
      case AvatarDetectionStatus.success:
        return AppColors.successGreen;
      default:
        return AppColors.white;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AvatarDetectionStatus.success:
        return AppColors.successGreen;
      default:
        return AppColors.black;
    }
  }

  String? get subtitle {
    switch (this) {
      case AvatarDetectionStatus.ok:
        return 'Please, wait 5 seconds to help us check';
      case AvatarDetectionStatus.tooHigh:
      case AvatarDetectionStatus.foreheadisNotVidible:
        return 'Tilt your face downward.';
      case AvatarDetectionStatus.tooLow:
      case AvatarDetectionStatus.chinIsNotVisible:
        return 'Tilt your face upward.';
      case AvatarDetectionStatus.notVisible:
        return 'Place your face in the mask so that it is completely inside the frame';
      case AvatarDetectionStatus.tooFar:
        return 'Your face image should fit mask fully';
      case AvatarDetectionStatus.closedEyes:
        return 'Look directly into the camera and try again';
      case AvatarDetectionStatus.lookStraight:
        return 'Hold the camera straight and try again';
      case AvatarDetectionStatus.tooBright:
        return 'Avoid bright light behind you and try again';
      case AvatarDetectionStatus.tooDark:
        return 'Move to a better-lit area and try again';
      case AvatarDetectionStatus.lowQuality:
        return 'Make sure your camera is clean and try again';
      case AvatarDetectionStatus.halfAttempts:
        return 'Please check recommendations and try again';
      case AvatarDetectionStatus.headwearIsOn:
        return 'Please remove them and try again';
      case AvatarDetectionStatus.notStarted:
      case AvatarDetectionStatus.undetected:
      case AvatarDetectionStatus.success:
        return null;
    }
  }

  String? get buttonTitle {
    switch (this) {
      case AvatarDetectionStatus.halfAttempts:
      case AvatarDetectionStatus.headwearIsOn:
        return 'Try again';
      default:
        return null;
    }
  }

  bool get isButtonEnabled {
    switch (this) {
      case AvatarDetectionStatus.halfAttempts:
      case AvatarDetectionStatus.headwearIsOn:
        return true;
      default:
        return false;
    }
  }

  String? get additionalButtonTitle {
    switch (this) {
      case AvatarDetectionStatus.halfAttempts:
        return 'Open recommendations';
      default:
        return null;
    }
  }

  bool get isAdditionalButtonEnabled {
    switch (this) {
      case AvatarDetectionStatus.halfAttempts:
        return true;
      default:
        return false;
    }
  }

  bool get isAutoHideDisabled {
    switch (this) {
      case AvatarDetectionStatus.headwearIsOn:
      case AvatarDetectionStatus.success:
      case AvatarDetectionStatus.ok:
      case AvatarDetectionStatus.halfAttempts:
        return true;
      default:
        return false;
    }
  }

  String? get image {
    switch (this) {
      case AvatarDetectionStatus.success:
        return 'packages/dataspikemobilesdk/assets/images/ok.svg';
      default:
        return null;
    }
  }
}
