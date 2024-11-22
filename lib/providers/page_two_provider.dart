import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:orchid_test_app/controllers/page_two_controller.dart';

class PageTwoProvider extends ChangeNotifier {
  final PageTwoController _pagetwoController = PageTwoController();

  List<String> getoptions = [];

  Future<void> loadgetData(BuildContext context) async {
    await _pagetwoController.getData("Aw", "N0000210").then((value) async {
      Logger().d("Fetching getData data");
      Logger().d(value.data);

      // Assuming value.data is a List of Maps
      if (value.data is List) {
        List<dynamic> rawData = value.data;
        getoptions = rawData.map((item) => item['DATA'].toString()).toList();
        Logger()
            .d('Fetched options: $getoptions'); // Debug log for fetched options
      } else {
        Logger().e('Unexpected data format: ${value.data}');
      }

      notifyListeners();
    }).catchError((error) {
      Logger().e('Error loading MOPMC data: $error');
      // notifyListeners();
    });
  }
}
