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

  undetected,
  notStarted,
  
  success;

  String get title {
    switch (this) {
      case AvatarDetectionStatus.ok:
        return 'Hold on!';
      case AvatarDetectionStatus.tooHigh:
        return 'Tilt your face downward.';
      case AvatarDetectionStatus.tooLow:
        return 'Tilt your face upward.';
      case AvatarDetectionStatus.notVisible:
        return 'Face in not entire inside mask ';
      case AvatarDetectionStatus.tooFar:
        return 'Move your face closer';
      case AvatarDetectionStatus.closedEyes:
        return 'Your eyes are closed';
      case AvatarDetectionStatus.lookStraight:
        return 'Face in not entire inside mask';
      case AvatarDetectionStatus.tooBright:
        return 'The image is too bright.';
      case AvatarDetectionStatus.tooDark:
        return 'The image is too dark.';
      case AvatarDetectionStatus.success:
        return 'Great. Check completed';
      case AvatarDetectionStatus.undetected:
      case AvatarDetectionStatus.notStarted:
        return '';
    }
  }

  bool get isVisible {
    switch (this) {
      case  AvatarDetectionStatus.notStarted:
      case AvatarDetectionStatus.undetected:
        return false;
      default:
        return true;
    }
  }

  bool get isScaled {
    switch (this) {
      case  AvatarDetectionStatus.notStarted:
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

  String? get subtitle {
    switch (this) {
      case AvatarDetectionStatus.ok:
        return 'Please, wait 5 seconds to help us check';
      case AvatarDetectionStatus.tooHigh:
        return 'Tilt your face downward.';
      case AvatarDetectionStatus.tooLow:
        return 'Tilt your face upward.';
      case AvatarDetectionStatus.notVisible:
        return 'Place your face in the mask so that it is completely inside the frame';
      case AvatarDetectionStatus.tooFar:
        return 'Your face image should fit mask fully';
      case AvatarDetectionStatus.closedEyes:
        return 'Please make sure they are open.';
      case AvatarDetectionStatus.lookStraight:
        return 'Please look straight at the camera.';
      case AvatarDetectionStatus.tooBright:
        return 'The image is too bright.';
      case AvatarDetectionStatus.tooDark:
        return 'The image is too dark.';
      case AvatarDetectionStatus.notStarted:
      case AvatarDetectionStatus.undetected:
      case AvatarDetectionStatus.success:
        return null;
    }
  }

  String? get image {
    switch (this) {
      default:
        return null;
    }
  }
}
