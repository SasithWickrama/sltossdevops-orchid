import 'package:orchid_test_app/models/login_response.dart';
import 'package:orchid_test_app/services/api_services.dart';

class LoginController {
  final ApiServices apiService;

  LoginController(this.apiService);

  Future<LoginResponse> login(String sid, String pwd) async {
    try {
      return await apiService.login(sid, pwd);
    } catch (e) {
      return LoginResponse(error: true, message: 'Failed to login');
    }
  }
}
