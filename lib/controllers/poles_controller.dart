import 'dart:convert';
import 'package:logger/logger.dart';
import 'dart:io';
// import 'package:cool_alert/cool_alert.dart';
import 'package:image/image.dart' as img;

import 'package:orchid_test_app/models/general_response.dart';
import 'package:orchid_test_app/services/api_services.dart';
import 'package:orchid_test_app/models/update_response.dart';

class PolesController {
  static const String defaultSid = '019413';

// Function to get data from the /uploadData endpoint
  Future<UploadDataResponse> uploadData2(
    String sid,
    String opmc,
    String lea,
    String area,
    String road,
    String poletype,
    String polesize,
    String selectedCategories,
    double lon,
    double lat,
  ) async {
    var body = jsonEncode(<String, dynamic>{
      "sid": sid,
      "mopmc": opmc,
      "lea": lea,
      "area": area,
      "road": road,
      "poletype": poletype,
      "polesize": polesize,
      'polerem': selectedCategories,
      "plon": lon.toString(),
      "plat": lat.toString(),
    });

    return await ApiServices().uploadPole(body);
  }

  final ApiServices _apiService = ApiServices();

  Future<GeneralResponse> handleResponses(dynamic response, File? _image1,
      File? _image2, File? _image3, File? _image4) async {
    GeneralResponse generalResponse;
    String regid = 'P' + response.message.toString().padLeft(7, '0');
    Logger().d("Generated regid: $regid");

    bool image1Success = true;
    bool image2Success = true;
    bool image3Success = true;
    bool image4Success = true;

    if (_image1 != null) {
      String imageFileName1 = '$regid\_POLE1.jpg';
      img.Image? originalImage1 = img.decodeImage(_image1.readAsBytesSync());
      img.Image resizedImage1 = img.copyResize(originalImage1!, width: 800);
      File compressedImage1 = File(_image1.path)
        ..writeAsBytesSync(img.encodeJpg(resizedImage1, quality: 85));
      await _apiService
          .uploadImage(compressedImage1, imageFileName1, regid)
          .then((value) async {
        Logger().d("image1");
        Logger().d(value);
        if (value.message != "File Uploaded Successfully") {
          image1Success = false;
        }
      });
    }

    if (_image2 != null) {
      String imageFileName2 = '$regid\_POLE2.jpg';
      img.Image? originalImage2 = img.decodeImage(_image2.readAsBytesSync());
      img.Image resizedImage2 = img.copyResize(originalImage2!, width: 800);
      File compressedImage2 = File(_image2.path)
        ..writeAsBytesSync(img.encodeJpg(resizedImage2, quality: 85));
      await _apiService
          .uploadImage(compressedImage2, imageFileName2, regid)
          .then((value) async {
        Logger().d("image2");
        Logger().d(value);
        if (value.message != "File Uploaded Successfully") {
          image2Success = false;
        }
      });
    }

    if (_image3 != null) {
      String imageFileName3 = '$regid\_POLE3.jpg';
      img.Image? originalImage3 = img.decodeImage(_image3.readAsBytesSync());
      img.Image resizedImage3 = img.copyResize(originalImage3!, width: 800);
      File compressedImage3 = File(_image3.path)
        ..writeAsBytesSync(img.encodeJpg(resizedImage3, quality: 85));
      await _apiService
          .uploadImage(compressedImage3, imageFileName3, regid)
          .then((value) async {
        Logger().d("image3");
        Logger().d(value);
        if (value.message != "File Uploaded Successfully") {
          image1Success = false;
        }
      });
    }

    if (_image4 != null) {
      String imageFileName4 = '$regid\_POLE4.jpg';
      img.Image? originalImage4 = img.decodeImage(_image4.readAsBytesSync());
      img.Image resizedImage4 = img.copyResize(originalImage4!, width: 800);
      File compressedImage4 = File(_image4.path)
        ..writeAsBytesSync(img.encodeJpg(resizedImage4, quality: 85));
      await _apiService
          .uploadImage(compressedImage4, imageFileName4, regid)
          .then((value) async {
        Logger().d("image4");
        Logger().d(value);
        if (value.message != "File Uploaded Successfully") {
          image1Success = false;
        }
      });
    }

    generalResponse = GeneralResponse(
      error:
          !(image1Success && image2Success && image3Success && image4Success),
      data: null,
    );

    return generalResponse;
  }
}
