import 'package:flutter/material.dart';
import 'package:orchid_test_app/controllers/login_controller.dart';
import 'package:orchid_test_app/models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orchid_test_app/widgets/shared_preferences..dart';

class LoginProvider with ChangeNotifier {
  final LoginController loginController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginProvider(this.loginController);

  Future<LoginResponse> login(String sid, String pwd) async {
    _isLoading = true;
    notifyListeners();

    final response = await loginController.login(sid, pwd);

    _isLoading = false;
    notifyListeners();

    SharedPref prefs = await SharedPref();
    prefs.savevalue("isLogged", "true");
    await prefs.savevalue('sid', sid);

    if (!response.error) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sid', sid);
      await prefs.setString('pwd', pwd);
    }

    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sid');
    await prefs.remove('pwd');
  }

  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    String? sid = prefs.getString('sid');
    String? pwd = prefs.getString('pwd');
    return {'sid': sid ?? '', 'pwd': pwd ?? ''};
  }

  Future<String?> getSid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sid');
  }
}
