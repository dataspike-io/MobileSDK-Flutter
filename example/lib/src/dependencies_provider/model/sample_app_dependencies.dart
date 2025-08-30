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
    dsApiToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJvMzU0ZDUyZjlmZDQzNDMyIiwidHBlIjoxLCJhcCI6bnVsbCwicyI6IjFmMDc2MWZlLTJiMmEtNmY0My05ZGNlLTI5MDc2ZTA1NjkwOSIsImlzcyI6ImRhdGFzcGlrZS5pbyJ9.cNjCgQf5WhAZJWHwFBTCFHD3gUE0tsIRG1mGWOe7xcc', 
    shortId: '',
  );
}