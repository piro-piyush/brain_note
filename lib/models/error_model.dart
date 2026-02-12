class ErrorModel {
  final String? error;
  final dynamic data;

  const ErrorModel({
    this.error,
    this.data,
  });

  bool get hasError => error != null;
}
