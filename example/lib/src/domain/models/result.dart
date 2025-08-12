class Result<T> {
  final T? value;
  final Object? error;
  bool get isSuccess => value != null;

  Result.success(this.value) : error = null;
  Result.failure(this.error) : value = null;
}