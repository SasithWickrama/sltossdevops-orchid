import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import 'package:orchid_test_app/providers/page_one_provider.dart';
import 'package:orchid_test_app/models/general_response.dart';
import 'package:orchid_test_app/services/api_services.dart';
import 'package:orchid_test_app/models/update_response.dart';
import 'package:orchid_test_app/models/detailed_response.dart';

class HomeController {
  // static const String defaultSid = '019413';
  // Function to get data from the /getMopmc endpoint
  Future<GeneralResponse> getMopmc(String sid) async {
    var body = jsonEncode(<String, String>{
      'sid': sid,
      // Add other necessary parameters here if required
    });

    return await ApiServices().getMopmc(body);
  }

  // Function to get data from the /getLea endpoint
  Future<GeneralResponse> getLea(String sid, String opmc) async {
    var body = jsonEncode(<String, String>{
      'sid': sid,
      "opmc": opmc,
      // Add other necessary parameters here if required
    });

    return await ApiServices().getLea(body);
  }

  // Function to get data from the /getMsan endpoint
  Future<GeneralResponse> getMsan(String sid, String lea) async {
    var body = jsonEncode(<String, String>{
      'sid': sid,
      "lea": lea,
      // Add other necessary parameters here if required
    });

    return await ApiServices().getMsan(body);
  }

//--------------------------------------------------------

  // Function to post data from the /uploadData endpoint
  Future<UploadDataResponse> uploadData(
      String sid,
      String opmc,
      String lea,
      String msan,
      String area,
      String road,
      String category,
      double lat,
      double lon,
      String category2) async {
    var body = jsonEncode(<String, String>{
      "sid": sid,
      "mopmc": opmc,
      "lea": lea,
      "msan": msan,
      "area": area,
      "road": road,
      "catagory": category,
      "lat": lat.toString(),
      "lon": lon.toString(),
      "catagory2": category2,
    });

    return await ApiServices().uploadData(body);
  }

  final ApiServices _apiService = ApiServices();

  Future<GeneralResponse> handleResponse(
      dynamic response, File? _image1, File? _image2) async {
    GeneralResponse generalResponse;
    String regid = 'N' + response.message.toString().padLeft(7, '0');
    Logger().d("Generated regid: $regid");

    bool image1Success = true;
    bool image2Success = true;

    if (_image1 != null) {
      String imageFileName1 = '$regid\_REP1.jpg';
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
      String imageFileName2 = '$regid\_REP2.jpg';
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

    generalResponse = GeneralResponse(
      error: !(image1Success && image2Success),
      data: null,
    );

    return generalResponse;
  }

  void setSid(BuildContext context, String sid) {
    Provider.of<PageOneProvider>(context, listen: false).setSid(sid);
  }

  void setSelectedMiniOPMC(BuildContext context, String mopmc) {
    Provider.of<PageOneProvider>(context, listen: false)
        .setSelectedMiniOPMC(mopmc);
  }

  void setMsan(BuildContext context, String msan) {
    Provider.of<PageOneProvider>(context, listen: false).setMsan(msan);
  }

  void setLea(BuildContext context, String lea) {
    Provider.of<PageOneProvider>(context, listen: false).setLea(lea);
  }

  void setArea(BuildContext context, String area) {
    Provider.of<PageOneProvider>(context, listen: false).setArea(area);
  }

  void setRoad(BuildContext context, String road) {
    Provider.of<PageOneProvider>(context, listen: false).setRoad(road);
  }

  void setSelectedCategory(BuildContext context, String category) {
    Provider.of<PageOneProvider>(context, listen: false)
        .setSelectedCategory(category);
  }

  void setCategory2(BuildContext context, String category2) {
    Provider.of<PageOneProvider>(context, listen: false)
        .setCategory2(category2);
  }

  // Function to get data from the /getLea endpoint
  Future<GeneralResponse> getData(String ref) async {
    var body = jsonEncode(<String, String>{
      "ref": ref,
      // Add other necessary parameters here if required
    });

    return await ApiServices().getData(body);
  }

  // Function to post data from the /uploadData endpoint
  Future<UploadDetailResponse> uploaddetailData(
      String sid,
      String ref,
      String comments,
      String wby,
      String start,
      String end,
      String cable,
      String pay) async {
    var body = jsonEncode(<String, String>{
      "sid": sid,
      "ref": ref,
      "comments": comments,
      "wby": wby,
      "start": start,
      "end": end,
      "cable": cable,
      "pay": pay
    });

    return await ApiServices().uploaddetailData(body);
  }

  Future<GeneralResponse> handleResponseNew(
      dynamic response, File? _image1, File? _image2) async {
    GeneralResponse generalResponse;
    String regid = response.message.toString();
    Logger().d("Generated regid: $regid");

    bool image1Success = true;
    bool image2Success = true;

    if (_image1 != null) {
      String imageFileName1 = '$regid\_FIX1.jpg';
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
      String imageFileName2 = '$regid\_FIX2.jpg';
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

    generalResponse = GeneralResponse(
      error: !(image1Success && image2Success),
      data: null,
    );

    return generalResponse;
  }
}
