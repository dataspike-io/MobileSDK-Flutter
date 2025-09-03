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
    dsApiToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJvMzU0ZDUyZjlmZDQzNDMyIiwidHBlIjoxLCJhcCI6bnVsbCwicyI6IjFmMDg4YzY2LWVkZjAtNjc1Ny05MGMxLWZhMWM2YjUyMmZiNSIsImlzcyI6ImRhdGFzcGlrZS5pbyJ9._z0L9KVqZs1qO7P1A7j9Hwa9QpCzFsKcrDBLZpeumL4', 
    shortId: '',
  );
}