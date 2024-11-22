import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'package:orchid_test_app/controllers/page_one_controller.dart';
import 'package:orchid_test_app/controllers/poles_controller.dart';

class PoleProvider extends ChangeNotifier {
  final _roadController = TextEditingController();
  TextEditingController get roadController => _roadController;

  // String roadname = "";
  var test2 = "";
  List<String> options = [];
  List<String> leaOptions = [];

  late String _sid;
  // String _sid = '019413';
  // String get sid => _sid;

  String? _mopmc;
  List<String> get items => options;
  String? get selectedMiniOPMC => _mopmc;

  String? _lea;
  List<String> get leaOptionss => leaOptions;
  String? get lea => _lea;

  String? _area;
  String? get area => _area;

  String? _poletype;
  String? get poletype => _poletype;

  String? _polesize;
  String? get polesize => _polesize;

  double? lat;
  double? lon;

  Position? _position;
  Position? get position => _position;

  late LocationSettings locationSettings;
  late StreamSubscription<Position> positionStream;

  bool _isUploading = false; // Track upload progress
  String _uploadStatus = '';

  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;

  void setSid(String value) {
    _sid = value;
    notifyListeners();
  }

  void setSelectedMiniOPMC(String value) {
    _mopmc = value;
    notifyListeners();
  }

  void setLea(String value) {
    _lea = value;
    notifyListeners();
  }

  void setLatLon(double latitude, double longitude) {
    lat = latitude;
    lon = longitude;
    notifyListeners();
  }

  void setArea(String value) {
    _area = value;
    notifyListeners();
  }

  void setPoleType(String value) {
    _poletype = value;
    notifyListeners();
  }

  void setPoleSize(String value) {
    _polesize = value;
    notifyListeners();
  }

  void setRoad(String value) {
    _roadController.text = value;
    // Update the provider state with the new value
    notifyListeners();
  }

  void clearRoad() {
    roadController.clear();
    notifyListeners();
  }

  List<String> categories = [
    'Cables attached to the pole',
    'DW attached to the pole',
    'No of cables / DWs attached to the pole',
    'FDP / DP pole'
  ];

  Map<String, bool> selectedCategories = {};

  PoleProvider() {
    // Initialize all categories as unselected
    for (var category in categories) {
      selectedCategories[category] = false;
    }
    _initializeSid();
  }

  Future<void> _initializeSid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sid = prefs.getString('sid') ?? '';
    notifyListeners();
  }

  CategoryProvider() {
    // Initialize all categories as unselected
    for (var category in categories) {
      selectedCategories[category] = false;
    }
  }

  void toggleCategorySelection(String category) {
    selectedCategories[category] = !(selectedCategories[category] ?? false);
    notifyListeners();
  }

  void selectAllCategories() {
    for (var category in categories) {
      selectedCategories[category] = true;
    }
    notifyListeners();
  }

  void clearAllCategories() {
    for (var category in categories) {
      selectedCategories[category] = false;
    }
    notifyListeners();
  }

  List<String> getSelectedCategories() {
    return selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void resetCategorySelection() {
    for (var category in categories) {
      selectedCategories[category] = false;
    }
    notifyListeners();
  }

  XFile? get image1 => image1;
  XFile? get image2 => image2;
  XFile? get image3 => image3;
  XFile? get image4 => image4;

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  void setImage1(XFile? image) {
    _image1 = _image1;
    notifyListeners();
  }

  void setImage2(XFile? image) {
    _image2 = _image2;
    notifyListeners();
  }

  void setImage3(XFile? image) {
    _image3 = _image3;
    notifyListeners();
  }

  void setImage4(XFile? image) {
    _image4 = _image4;
    notifyListeners();
  }

  final HomeController _homeController = HomeController();

  final PolesController _poleController = PolesController();

  Future<void> loadData(BuildContext context) async {
    await _homeController.getMopmc("AD").then((value) async {
      Logger().d("Fetching MOPMC data");
      Logger().d(value.data);
      test2 = value.data.toString();

      // Assuming value.data is a List of Maps
      if (value.data is List) {
        List<dynamic> rawData = value.data;
        options = rawData.map((item) => item['DATA'].toString()).toList();
        Logger()
            .d('Fetched options: $options'); // Debug log for fetched options
      } else {
        Logger().e('Unexpected data format: ${value.data}');
      }

      notifyListeners();
    }).catchError((error) {
      Logger().e('Error loading MOPMC data: $error');
      // notifyListeners();
    });
  }

  Future<void> loadLeaData(String miniOpmc) async {
    await _homeController.getLea(miniOpmc, miniOpmc).then((value) async {
      Logger().d("Fetching LEA data");
      Logger().d(value.data);

      if (value.data is List) {
        List<dynamic> rawData = value.data;
        leaOptions = rawData.map((item) => item['DATA'].toString()).toList();
        Logger().d(
            'Fetched LEA options: $leaOptions'); // Debug log for fetched options
      } else {
        Logger().e('Unexpected data format: ${value.data}');
      }

      notifyListeners();
    }).catchError((error) {
      Logger().e('Error loading LEA data: $error');
    });
  }

  Future<void> fetchCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, show alert to the user
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: 'Location Services Disabled',
        text: 'Please enable location services to use this feature.',
      );
      throw 'Location services are disabled.';
    }

    // Request permission to use location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show alert to the user
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: 'Location Permissions Denied',
          text: 'Please grant permission to access device location.',
        );
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately.
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: 'Location Permissions Denied',
        text:
            'Location permissions are permanently denied. Please enable them in settings.',
      );
      throw 'Location permissions are permanently denied.';
    }

    // Get the current position
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (_position != null) {
      lat = _position!.latitude;
      lon = _position!.longitude;
      Logger().d('Current location: ($lat, $lon)');
    } else {
      Logger().e('Failed to get current location.');
      throw 'Failed to get current location.';
    }
  }

//--------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
  Future<void> submitData(BuildContext context, File? _image1, File? _image2,
      File? _image3, File? _image4) async {
    _isUploading = true;
    notifyListeners();

    await fetchCurrentLocation(context);

    if (lat == null || lon == null) {
      Logger().e('Latitude or Longitude is null');
      context.loaderOverlay.hide();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: 'Error',
        text: 'Latitude or Longitude is null',
      );
      _isUploading = false;
      notifyListeners();
      return;
    }

    try {
      List<String> selectedCategories = getSelectedCategories();
      String polerem = selectedCategories
          .join(', '); // Convert the list to a comma-separated string

      await _poleController
          .uploadData2(
        _sid,
        _mopmc ?? '',
        _lea ?? '',
        _area ?? '',
        _roadController.text,
        _poletype ?? '',
        _polesize ?? '',
        polerem,
        lat!,
        lon!,
      )
          .then((uploadResponse) async {
        Logger().d(uploadResponse.message);
        Logger().d("upload pole data");

        if (!uploadResponse.error) {
          // Check if _image1 or _image2 is not null
          if (_image1 != null ||
              _image2 != null ||
              _image3 != null ||
              _image4 != null) {
            await _poleController
                .handleResponses(
              uploadResponse,
              _image1,
              _image2,
              _image3,
              _image4,
            )
                .then((imageResponse) {
              Logger().d(imageResponse);

              context.loaderOverlay.hide(); // Hide the loader here

              if (imageResponse.error) {
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  title: 'Success',
                  text: 'Data and images uploaded successfully!',
                  onConfirmBtnTap: () {
                    // clear();
                    // clearFormData(context);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                );
              } else {
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.error,
                  title: 'Error',
                  text: 'Image upload failed.',
                );
              }
            });
          } else {
            context.loaderOverlay.hide(); // Hide the loader here

            // No images to upload, just show success alert
            CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              title: 'Success',
              text: 'Data uploaded successfully!',
              onConfirmBtnTap: () {
                // clear();
                // clearFormData(context);
              },
            );
          }
        } else {
          context.loaderOverlay.hide(); // Hide the loader here

          Logger().e("Data upload failed: ${uploadResponse.message}");
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: 'Error',
            text: 'Data upload failed: ${uploadResponse.message}',
          );
        }
      });

      notifyListeners();
    } catch (error) {
      Logger().e('Error loading upload data: $error');
      context.loaderOverlay.hide(); // Hide the loader here
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: 'Error',
        text: 'Error loading upload data: $error',
      );
    }
    // });

    notifyListeners();

    _isUploading = false;
    notifyListeners();
  }
}
