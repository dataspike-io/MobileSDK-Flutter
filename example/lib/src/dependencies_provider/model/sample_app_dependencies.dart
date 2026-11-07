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
    dsApiToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJvMzU0ZDUyZjlmZDQzNDMyIiwidHBlIjoxLCJhcCI6bnVsbCwicyI6IjFmMTE3MzM5LWNhY2EtNmQ0Ni1iMjZjLTVkNDlhODc0ZTk2MyIsImlzcyI6ImRhdGFzcGlrZS5pbyJ9.68LhQNNxIbueROud2NWV6q9o_LKOmHXHEPQVM1LlKT0', 
    shortId: '',
  );
}