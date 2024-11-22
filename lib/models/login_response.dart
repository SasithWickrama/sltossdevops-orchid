class LoginResponse {
  final bool error;
  final String message;

  LoginResponse({
    this.error = true,
    this.message = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> responsejson) {
    final error1 = responsejson['error'] as bool;
    final message = responsejson['message'] as String;

    return LoginResponse(error: error1, message: message);
  }
}
