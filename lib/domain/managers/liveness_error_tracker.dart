import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';

/// Front-side errors that go through the Tier 1 -> 2 -> 3 escalation.
/// Each group has its own consecutive-frame counter.
enum LivenessErrorGroup {
  faceNotInFrame(hintThreshold: 2),
  // Highest false-positive rate (blinking), hence the higher threshold.
  eyesNotDetected(hintThreshold: 4),
  lighting(hintThreshold: 2),
  imageQuality(hintThreshold: 2);

  const LivenessErrorGroup({required this.hintThreshold});

  /// Consecutive frames with the error before the Tier 2 hint is shown.
  final int hintThreshold;

  /// Consecutive frames before Tier 3: [LivenessErrorTracker.framesAfterHint]
  /// more frames after the one that triggered the hint.
  int get interruptionThreshold =>
      hintThreshold + LivenessErrorTracker.framesAfterHint;
}

extension LivenessErrorGroupX on AvatarDetectionStatus {
  /// The escalation group of a front-side error, `null` for statuses that
  /// are not front errors (ok, timers, backend errors, ...).
  LivenessErrorGroup? get errorGroup {
    switch (this) {
      case AvatarDetectionStatus.notVisible:
      case AvatarDetectionStatus.chinIsNotVisible:
      case AvatarDetectionStatus.foreheadisNotVidible:
      case AvatarDetectionStatus.tooFar:
      case AvatarDetectionStatus.tooHigh:
      case AvatarDetectionStatus.tooLow:
      case AvatarDetectionStatus.lookStraight:
        return LivenessErrorGroup.faceNotInFrame;
      case AvatarDetectionStatus.closedEyes:
        return LivenessErrorGroup.eyesNotDetected;
      case AvatarDetectionStatus.tooBright:
      case AvatarDetectionStatus.tooDark:
        return LivenessErrorGroup.lighting;
      case AvatarDetectionStatus.lowQuality:
        return LivenessErrorGroup.imageQuality;
      default:
        return null;
    }
  }
}

/// What the UI should do for one analyzed frame.
enum LivenessFrameOutcome {
  /// The error is present but nothing new to show: the oval is red, and a
  /// Tier 2 hint that is already on screen keeps running.
  visual,

  /// The hint threshold was just reached: show the Tier 2 hint.
  showHint,

  /// The Tier 3 threshold is reached. The UI must defer the interruption
  /// while a hint is still visible (see [LivenessErrorTracker.isInterruptionDue]).
  interrupt,
}

/// Frame-based escalation of a persisting front error.
///
/// Only one error can be reported per frame, so a single counter is enough:
/// a different group, or a clean frame, starts a new cycle.
class LivenessErrorTracker {
  /// Frames that must follow the hint-triggering frame before Tier 3.
  static const int framesAfterHint = 4;

  LivenessErrorGroup? _group;
  int _count = 0;
  bool _hintShown = false;

  /// True once the current error has persisted long enough for Tier 3.
  bool get isInterruptionDue =>
      _group != null && _count >= _group!.interruptionThreshold;

  /// Feeds one analyzed frame. Pass the error group of the frame, or `null`
  /// when the frame has no error.
  LivenessFrameOutcome? onFrame(LivenessErrorGroup? group) {
    if (group == null) {
      reset();
      return null;
    }

    if (group != _group) {
      _group = group;
      _count = 0;
      _hintShown = false;
    }
    _count++;

    if (_count >= group.interruptionThreshold) {
      return LivenessFrameOutcome.interrupt;
    }
    if (_count >= group.hintThreshold && !_hintShown) {
      _hintShown = true;
      return LivenessFrameOutcome.showHint;
    }
    return LivenessFrameOutcome.visual;
  }

  void reset() {
    _group = null;
    _count = 0;
    _hintShown = false;
  }
}
