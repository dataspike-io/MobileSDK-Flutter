class HttpException implements Exception {
  final Map<String, dynamic> errorBody;
  HttpException(this.errorBody);
}