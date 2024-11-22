// import 'dart:convert';
import 'package:orchid_test_app/models/general_response.dart';
import 'package:orchid_test_app/services/api_services.dart';

class PageTwoController {
  Future<GeneralResponse> getData(String sid, String ref) async {
    var body = {
      'sid': sid,
      'ref': ref,
    };

    return await ApiServices().getData(body);
  }
}
