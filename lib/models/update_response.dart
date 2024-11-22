class UploadDataResponse {
  final bool error;
  final int message;

  UploadDataResponse({
    required this.error,
    required this.message,
  });

  factory UploadDataResponse.fromJson(Map<String, dynamic> responsejson) {
    final error1 = responsejson['error'] as bool;
    final message1 = responsejson['message'] as int;

    return UploadDataResponse(error: error1, message: message1);
  }
}
