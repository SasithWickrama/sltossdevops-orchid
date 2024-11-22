class GeneralResponse {
  final bool error;
  var data;

  GeneralResponse({this.error = true, this.data = null});

  factory GeneralResponse.fromJson(Map<String, dynamic> responsejson) {
    //response variables
    final error1 = responsejson['error'] as bool;
    // final message1 = responsejson['message'] as String;
    final data1 = responsejson['data'] ?? "";

    return GeneralResponse(error: error1, data: data1);
  }
}
