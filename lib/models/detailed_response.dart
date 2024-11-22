class UploadDetailResponse {
  final bool error;
  final String message;

  UploadDetailResponse({
    this.error = true,
    this.message = '',
  });

  factory UploadDetailResponse.fromJson(Map<String, dynamic> responsejson) {
    final error1 = responsejson['error'] as bool;
    final message1 = responsejson['message'] as String;

    return UploadDetailResponse(error: error1, message: message1);
  }
}
