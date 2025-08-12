class SampleAppDependencies {
  final bool isDebug;
  final String dsApiToken;
  final String shortId;

  const SampleAppDependencies({
    required this.isDebug,
    required this.dsApiToken,
    required this.shortId,
  });

  static const dependencies = SampleAppDependencies(
    isDebug: true,
    dsApiToken: '', 
    shortId: '',
  );
}