import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:async';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

import 'package:orchid_test_app/controllers/page_one_controller.dart';

class PageOneProvider extends ChangeNotifier {
  final _roadController = TextEditingController();
  TextEditingController get roadController => _roadController;

  // String roadname = "";
  // var test = "";
  dynamic test;
  List<String> options = [];
  List<String> leaOptions = [];
  List<String> msanOptions = [];
  List<String> imageUrls = [];

  // final String sid;

  // PageOneProvider({required this.sid});

  // String _sid = '019413';
  late String _sid;
  String _category2 = '';

  String? _mopmc;
  List<String> get items => options;
  String? get selectedMiniOPMC => _mopmc;

  String? _lea;
  List<String> get leaOptionss => leaOptions;
  String? get lea => _lea;

  String? _msan;
  List<String> get msanOptionss => msanOptions;
  String? get msan => _msan;

  String? _area;
  String? get area => _area;
//--------------------------------------

  String _ref;

  // PageOneProvider(this._ref);

  String get ref => _ref;

  void updateRef(String newRef) {
    _ref = newRef;
    notifyListeners();
  }

  final _commentsController = TextEditingController();
  TextEditingController get commentsController => _commentsController;

  String? _wby;
  String? get wby => _wby;

  final _startController = TextEditingController();
  TextEditingController get startController => _startController;

  final _endController = TextEditingController();
  TextEditingController get endController => _endController;

  final _cableController = TextEditingController();
  TextEditingController get cableController => _cableController;

  String? _pay;
  String? get pay => _pay;

  //-------------------------------------------

  String _selectedCategory = '';
  Map<String, bool> _category1Options = {
    'Slant Pole': false,
    'Damage Pole': false,
    'Wire Hanging': false,
  };

  Map<String, bool> _category2Options = {
    'DP Replace': false,
    'Drop wire bunch replace': false,
    'Drop wire rearrange': false,
  };

  // Getters
  String get selectedCategory => _selectedCategory;
  Map<String, bool> get category1Options => _category1Options;
  Map<String, bool> get category2Options => _category2Options;

  double? lat;
  double? lon;

  Position? _position;
  Position? get position => _position;

  late LocationSettings locationSettings;
  late StreamSubscription<Position> positionStream;

  File? _image1;
  File? _image2;
  bool _isUploading = false; // Track upload progress
  String _uploadStatus = '';

  bool get isUploading => _isUploading;
  String get uploadStatus => _uploadStatus;

  PageOneProvider(this._ref) {
    _initializeSid();
  }

  Future<void> _initializeSid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sid = prefs.getString('sid') ?? '';
    notifyListeners();
  }

//---------------------------------------------------------------------------------

  final HomeController _homeController = HomeController();

  Future<void> loadData(BuildContext context) async {
    await _homeController.getMopmc("AD").then((value) async {
      Logger().d("Fetching MOPMC data");
      Logger().d(value.data);
      // test2 = value.data.toString();

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

  Future<void> loadMsanData(
      BuildContext context, String miniOpmc, String lea) async {
    await _homeController.getMsan(miniOpmc, lea).then((value) async {
      Logger().d("Fetching MSAN data");
      Logger().d(value.data);

      if (value.data is List) {
        List<dynamic> rawData = value.data;
        msanOptions = rawData.map((item) => item['DATA'].toString()).toList();
        Logger().d(
            'Fetched MSAN options: $msanOptions'); // Debug log for fetched options
      } else {
        Logger().e('Unexpected data format: ${value.data}');
      }

      notifyListeners();
    }).catchError((error) {
      Logger().e('Error loading MSAN data: $error');
    });
  }

  Future<void> submitDataNew(
      BuildContext context, File? _image1, File? _image2) async {
    _isUploading = true;
    notifyListeners();

    List<String> selectedCategory1Options = _category1Options.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    List<String> selectedCategory2Options = _category2Options.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    String selectedOptions = '';

    if (_selectedCategory == 'Category 1') {
      selectedOptions = selectedCategory1Options.join(', ');
    } else if (_selectedCategory == 'Category 2') {
      selectedOptions = selectedCategory2Options.join(', ');
    }

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
      await _homeController
          .uploadData(
        _sid,
        _mopmc ?? '',
        _lea ?? '',
        _msan ?? '',
        _area ?? '',
        _roadController.text,
        selectedOptions,
        lat!,
        lon!,
        _category2,
      )
          .then((uploadResponse) async {
        Logger().d(uploadResponse.message);

        if (!uploadResponse.error) {
          // Check if _image1 or _image2 is not null
          if (_image1 != null || _image2 != null) {
            await _homeController
                .handleResponse(
              uploadResponse,
              _image1,
              _image2,
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
                    clear();
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
                clear();
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

    _isUploading = false;
    notifyListeners();
  }

  Future<void> getImage(int imageNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (imageNumber == 1) {
        _image1 = File(pickedFile.path);
      } else if (imageNumber == 2) {
        _image2 = File(pickedFile.path);
      }
      notifyListeners();
    } else {
      print('No image selected.');
    }
  }

  // Getters
  String get sid => _sid;

  String get category2 => _category2;

  XFile? get image1 => image1;
  XFile? get image2 => image2;

  // Setters
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

  void setMsan(String value) {
    _msan = value;
    notifyListeners();
  }

  void setArea(String value) {
    _area = value;
    notifyListeners();
  }

  void setRoad(String value) {
    _roadController.text = value;
    notifyListeners();
  }

  // Setters
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateCategory1Option(String option, bool value) {
    _category1Options[option] = value;
    notifyListeners();
  }

  void updateCategory2Option(String option, bool value) {
    _category2Options[option] = value;
    notifyListeners();
  }

  void selectAllCategory1Options() {
    _category1Options.updateAll((key, value) => true);
    notifyListeners();
  }

  void clearCategory1Options() {
    _category1Options.updateAll((key, value) => false);
    notifyListeners();
  }

  void selectAllCategory2Options() {
    _category2Options.updateAll((key, value) => true);
    notifyListeners();
  }

  void clearCategory2Options() {
    _category2Options.updateAll((key, value) => false);
    notifyListeners();
  }

  void setCategory2(String value) {
    _category2 = value;
    notifyListeners();
  }

  void setLatLon(double latitude, double longitude) {
    lat = latitude;
    lon = longitude;
    notifyListeners();
  }

  void setImage1(XFile? image) {
    _image1 = _image1;
    notifyListeners();
  }

  void setImage2(XFile? image) {
    _image2 = _image2;
    notifyListeners();
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
      // here exchange lat and lon according to backend API
      lat = _position!.longitude;
      lon = _position!.latitude;
      Logger().d('Current location: ($lat, $lon)');
    } else {
      Logger().e('Failed to get current location.');
      throw 'Failed to get current location.';
    }
  }

  Future<void> loadGetData(BuildContext context, String ref) async {
    await _homeController.getData(ref).then((value) async {
      Logger().d(value.data); // Log the data
      test = value.data;
      notifyListeners();
    });
  }

  Future<void> submitDetailData(
      BuildContext context, File? _image1, File? _image2) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _homeController
          .uploaddetailData(
        _sid,
        _ref,
        commentsController.text,
        _wby ?? '',
        startController.text,
        endController.text,
        cableController.text,
        _pay ?? '',
      )
          .then((uploadResponse) async {
        Logger().d(uploadResponse.message);

        if (!uploadResponse.error) {
          // Check if _image1 or _image2 is not null
          if (_image1 != null || _image2 != null) {
            await _homeController
                .handleResponseNew(
              uploadResponse,
              _image1,
              _image2,
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
                    clear();
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
                clear();
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

    _isUploading = false;
    notifyListeners();
  }

  void setComment(String value) {
    _commentsController.text = value;
    notifyListeners();
  }

  void setWby(String value) {
    _wby = value;
    notifyListeners();
  }

  void setStart(String value) {
    _startController.text = value;
    notifyListeners();
  }

  void setEnd(String value) {
    _endController.text = value;
    notifyListeners();
  }

  void setCable(String value) {
    _cableController.text = value;
    notifyListeners();
  }

  void setPay(String value) {
    _pay = value;
    notifyListeners();
  }

  void clear() {
    setSelectedMiniOPMC("");
    setLea("");
    setMsan("");
    setArea("");
    setRoad("");
    setSelectedCategory("");
    _category1Options.updateAll((key, value) => false);
    _category2Options.updateAll((key, value) => false);
    _image1 = null;
    _image2 = null;
  }
}
