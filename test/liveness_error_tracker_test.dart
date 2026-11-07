import 'package:dataspikemobilesdk/domain/managers/liveness_error_tracker.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dark = LivenessErrorGroup.lighting;
  const eyes = LivenessErrorGroup.eyesNotDetected;

  List<LivenessFrameOutcome?> feed(
    LivenessErrorTracker tracker,
    LivenessErrorGroup? group,
    int frames,
  ) => [for (var i = 0; i < frames; i++) tracker.onFrame(group)];

  test('escalates visual -> hint -> silent -> interruption', () {
    final tracker = LivenessErrorTracker();

    expect(feed(tracker, dark, 6), [
      LivenessFrameOutcome.visual, // frame 1: Tier 1
      LivenessFrameOutcome.showHint, // frame 2: Tier 2
      LivenessFrameOutcome.visual, // frames 3-5: silent
      LivenessFrameOutcome.visual,
      LivenessFrameOutcome.visual,
      LivenessFrameOutcome.interrupt, // frame 6: 4 frames after the hint
    ]);
    expect(tracker.isInterruptionDue, isTrue);
  });

  test('hint is shown once per cycle', () {
    final tracker = LivenessErrorTracker();
    final outcomes = feed(tracker, dark, 5);

    expect(
      outcomes.where((o) => o == LivenessFrameOutcome.showHint),
      hasLength(1),
    );
  });

  test('a clean frame resets the counter and starts Tier 1 again', () {
    final tracker = LivenessErrorTracker();

    feed(tracker, dark, 2);
    expect(tracker.onFrame(null), isNull);
    expect(tracker.isInterruptionDue, isFalse);
    expect(tracker.onFrame(dark), LivenessFrameOutcome.visual);
    expect(tracker.onFrame(dark), LivenessFrameOutcome.showHint);
  });

  test('eyes not detected needs 4 frames for the hint and 8 for Tier 3', () {
    final tracker = LivenessErrorTracker();

    expect(feed(tracker, eyes, 8), [
      ...List.filled(3, LivenessFrameOutcome.visual),
      LivenessFrameOutcome.showHint,
      ...List.filled(3, LivenessFrameOutcome.visual),
      LivenessFrameOutcome.interrupt,
    ]);
  });

  test('a different error group starts its own cycle', () {
    final tracker = LivenessErrorTracker();

    feed(tracker, dark, 2);
    expect(
      tracker.onFrame(LivenessErrorGroup.faceNotInFrame),
      LivenessFrameOutcome.visual,
    );
  });

  test('interruption stays due until reset', () {
    final tracker = LivenessErrorTracker();

    feed(tracker, dark, 6);
    expect(tracker.onFrame(dark), LivenessFrameOutcome.interrupt);

    tracker.reset();
    expect(tracker.isInterruptionDue, isFalse);
    expect(tracker.onFrame(dark), LivenessFrameOutcome.visual);
  });

  test('front statuses map to their escalation groups', () {
    expect(AvatarDetectionStatus.tooDark.errorGroup, dark);
    expect(AvatarDetectionStatus.tooBright.errorGroup, dark);
    expect(AvatarDetectionStatus.closedEyes.errorGroup, eyes);
    expect(
      AvatarDetectionStatus.lookStraight.errorGroup,
      LivenessErrorGroup.faceNotInFrame,
    );
    expect(
      AvatarDetectionStatus.lowQuality.errorGroup,
      LivenessErrorGroup.imageQuality,
    );
    expect(AvatarDetectionStatus.ok.errorGroup, isNull);
    expect(AvatarDetectionStatus.headwearIsOn.errorGroup, isNull);
  });
}
