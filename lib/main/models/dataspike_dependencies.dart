class DataspikeDependencies {
  final bool isDebug;
  final String dsApiToken;
  final String shortId;

  /// Debug: show the raw on-device ML scores over the selfie camera.
  final bool showMlScores;

  /// Debug: after loading the verification go straight to the selfie camera,
  /// skipping onboarding, personal data, documents and instructions.
  final bool livenessOnly;

  /// Debug: run the liveness checks without uploading anything. Reaching
  /// the green state only shows it; no frames are captured or sent and
  /// detection keeps running.
  final bool livenessDryRun;

  const DataspikeDependencies({
    required this.isDebug,
    required this.dsApiToken,
    required this.shortId,
    this.showMlScores = false,
    this.livenessOnly = false,
    this.livenessDryRun = false,
  });
}