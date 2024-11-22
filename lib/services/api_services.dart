import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'package:orchid_test_app/models/general_response.dart';
import 'package:orchid_test_app/models/update_response.dart';
import 'package:orchid_test_app/util/assets_constant.dart';
import 'package:orchid_test_app/models/login_response.dart';
import 'package:orchid_test_app/models/detailed_response.dart';

class ApiServices {
  Future<LoginResponse> login(String sid, String pwd) async {
    final response = await http.post(
      Uri.parse('${AssetsConstant.baseUrl}/userLogin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'sid': sid,
        'pwd': pwd,
        'appversion': AssetsConstant.appver,
      }),
    );

    if (response.statusCode == 202) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  // Future<GenaralResponce2> sendRequest(String function, var inputlist) async {
  //   Uri url = Uri(
  //     scheme: AssetsConstant.apiScheema1,
  //     host: AssetsConstant.apihost1,
  //     path: '${AssetsConstant.apipath1}$function',
  //   );
  //   GenaralResponce2 newResponce;
  //   Logger().i(function);
  //   Logger().i(inputlist);
  //   try {
  //     final response = await http.post(url,
  //         headers: {"HttpHeaders.contentTypeHeader": "application/json"},
  //         body: inputlist);

  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       //Logger().i(responseData);
  //       newResponce = GenaralResponce2(
  //           error: responseData['error'],
  //           message: responseData['message'],
  //           data: responseData['data']);
  //     } else {
  //       newResponce = GenaralResponce2(
  //           error: true, message: 'API Error Code:${response.statusCode} ');
  //     }
  //   } catch (e) {
  //     newResponce = GenaralResponce2(
  //         error: true, message: 'Connection Error Code:${e.toString()} ');
  //   }

  //   return newResponce;
  // }

  //--------------------------------------------------------------------

  Future<GeneralResponse> getMopmc(var body) async {
    GeneralResponse generalResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/getMopmc');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d("Fetching Mini OPMC data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      generalResponse = GeneralResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching Mini OPMC data: $e");
      generalResponse = GeneralResponse(error: true);
    }
    return generalResponse;
  }

  Future<GeneralResponse> getLea(var body) async {
    GeneralResponse generalResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/getLea');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d("Fetching LEA data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      generalResponse = GeneralResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching LEA data: $e");
      generalResponse = GeneralResponse(error: true);
    }
    return generalResponse;
  }

  Future<GeneralResponse> getMsan(var body) async {
    GeneralResponse generalResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/getMsan');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d("Fetching MSAN data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      generalResponse = GeneralResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching MSAN data: $e");
      generalResponse = GeneralResponse(error: true);
    }
    return generalResponse;
  }

  Future<UploadDataResponse> uploadData(var body) async {
    UploadDataResponse uploadDataResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/uploadData');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d(body);
      // Logger().d("Fetching uploadData data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      uploadDataResponse = UploadDataResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching uploadData data: $e");
      uploadDataResponse = UploadDataResponse(error: true, message: 1);
    }
    return uploadDataResponse;
  }

  final Dio _dio = Dio();

  static const String ImageUrl = "http://124.43.128.239/ApiOrchid/ImageApi/";

  Future<UploadDataResponse> uploadImage(
      File imageFile, String fileName, String regId) async {
    try {
      // Create a new form data instance
      FormData formData = FormData();

      // Add fields to form data manually
      formData.fields.addAll([
        MapEntry('desc', fileName),
        MapEntry('location', regId),
      ]);

      // Append the file as a MultipartFile
      // Since imageFile is not nullable (based on how it's passed), no need for null check
      formData.files.add(MapEntry(
        'image',
        MultipartFile.fromFileSync(imageFile.path, filename: fileName),
      ));

      // Log form data for debugging
      Logger().d("FormData: ${formData.fields}");

      // Send POST request to upload the file
      final response = await _dio.post(
        '${AssetsConstant.ImageUrl}/ApiImage.php?apicall=upload',
        data: formData,
      );

      // Log the response from the server
      Logger().d("Response: ${response.data}");

      final responseData = response.data;
      Logger().d("response");
      Logger().d(
          "Parameters: image=${imageFile.path}, desc=$fileName, location=$regId");

      // Check if the response is a string, indicating an error
      if (responseData is String) {
        Logger().e("Unexpected response format: $responseData");
        return UploadDataResponse(error: true, message: 123);
      } else {
        return UploadDataResponse.fromJson(responseData);
      }
    } catch (error) {
      Logger().e('Error uploading image: $error');
      print('Error uploading image: $error');
      throw error; // Re-throw the error to handle it in your UI or provider
    }
  }

  Future<UploadDataResponse> uploadPole(var body) async {
    UploadDataResponse uploadDataResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/uploadPoleData');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d(body);
      // Logger().d("Fetching uploadData data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      uploadDataResponse = UploadDataResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching uploadData data: $e");
      uploadDataResponse = UploadDataResponse(error: true, message: 1);
    }
    return uploadDataResponse;
  }

//----------------------------------------------------------------------

  Future<GeneralResponse> getData(var body) async {
    GeneralResponse generalResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/getData');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d("Fetching Ref data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      generalResponse = GeneralResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching Ref data: $e");
      generalResponse = GeneralResponse(error: true);
    }
    return generalResponse;
  }

  Future<UploadDetailResponse> uploaddetailData(var body) async {
    UploadDetailResponse uploadDataResponse;

    Uri url = Uri.parse('${AssetsConstant.baseUrl}/updateFixV2');
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      Logger().d(body);
      // Logger().d("Fetching uploadData data");

      final response = await http.post(url, headers: header, body: body);
      final data = json.decode(response.body);
      Logger().d(data);

      uploadDataResponse = UploadDetailResponse.fromJson(data);
    } catch (e) {
      Logger().e("Error fetching uploadData data: $e");
      uploadDataResponse = UploadDetailResponse(
          error: true, message: 'Connection Error: ${e.toString()}');
    }
    return uploadDataResponse;
  }
}
