import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orchid_test_app/screens/login.dart';
import 'package:orchid_test_app/screens/home.dart'; // Ensure you have this import for the home screen
// import 'package:orchid_test_app/widgets/shared_preferences..dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    determineGreetingMessage();
    checkLoginStatus();
  }

  String greetingMessage = "";

  void determineGreetingMessage() {
    String tdata = DateFormat("HH").format(DateTime.now());
    if (int.parse(tdata) < 12 && int.parse(tdata) > 5) {
      greetingMessage = "Good Morning!";
    } else if (int.parse(tdata) < 17) {
      greetingMessage = "Good Afternoon!";
    } else {
      greetingMessage = "Good Evening!";
    }
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getString('isLogged') ?? 'false';
    final sid = prefs.getString('sid') ?? '';

    Timer(Duration(seconds: 3), () {
      if (isLogged == 'true' && sid.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(sid: sid),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 235, 237, 240),
              Color.fromARGB(255, 170, 188, 192),
            ], // Set your gradient colors here
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Your image goes here
                      Gif(
                        autostart: Autostart.once,
                        placeholder: (context) =>
                            Center(child: CircularProgressIndicator()),
                        image: AssetImage('assets/images/notify.gif'),
                        width: 250.0,
                        height: 250.0,
                      ),
                      SizedBox(height: 24),
                      Text(
                        greetingMessage,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color.fromARGB(
                              255, 5, 140, 202), // Change text color as needed
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: 200, // Set the width of the progress indicator
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add the text widget at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ORCHID',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Color.fromARGB(
                      255, 255, 230, 0), // Change text color as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
