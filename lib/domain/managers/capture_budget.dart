/// Time allowed to collect the liveness photos.
///
/// Every candidate photo is validated on-device before it is accepted, and
/// that takes a very different time on different phones. A fixed timeout
/// that suits a fast phone cannot even fit the photos on a slow one, so the
/// budget grows with the measured validation time: enough for every photo
/// to send plus a few rejected candidates, never below [baseTimeout] and
/// never above [maxTimeout].
class CaptureBudget {
  CaptureBudget({
    required this.baseTimeout,
    required this.maxTimeout,
    required this.photosToSend,
    required this.spareCandidates,
    required this.frameGap,
  });

  /// Timeout of a fast device, and the floor for every device.
  final Duration baseTimeout;

  /// Upper bound, so a hopeless capture still ends.
  final Duration maxTimeout;

  /// Photos that have to be accepted.
  final int photosToSend;

  /// Candidates that may be rejected on top of [photosToSend].
  final int spareCandidates;

  /// Minimum gap between two accepted photos.
  final Duration frameGap;

  Duration _totalValidation = Duration.zero;
  int _validations = 0;

  /// Records how long validating one candidate photo took.
  void recordValidation(Duration duration) {
    _totalValidation += duration;
    _validations++;
  }

  /// The timeout for the whole capture, counted from its start.
  Duration get timeout {
    if (_validations == 0) return baseTimeout;

    final average = _totalValidation ~/ _validations;
    final needed = (average + frameGap) * (photosToSend + spareCandidates);

    if (needed < baseTimeout) return baseTimeout;
    if (needed > maxTimeout) return maxTimeout;
    return needed;
  }
}
