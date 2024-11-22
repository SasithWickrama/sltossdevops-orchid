import 'package:flutter/material.dart';
import 'package:orchid_test_app/providers/login_provider.dart';
import 'package:orchid_test_app/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:gif/gif.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _sidController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderOverlay(
        useDefaultLoading: false,
        overlayColor: Colors.black.withOpacity(0.5),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 235, 237, 240),
                Color.fromARGB(255, 170, 188, 192),
              ],
            ),
          ),
          child: Center(
            child: Consumer<LoginProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Gif(
                          autostart: Autostart.once,
                          placeholder: (context) =>
                              Center(child: CircularProgressIndicator()),
                          image: AssetImage('assets/images/notify.gif'),
                          width: 200.0,
                          height: 150.0,
                        ),
                        Center(
                          child: Text(
                            'ORCHID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 230, 0),
                              fontSize: 30,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _sidController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            labelText: 'Username',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 31, 68, 133)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _pwdController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 31, 68, 133)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            context.loaderOverlay.show();
                            final response = await provider.login(
                              _sidController.text,
                              _pwdController.text,
                            );
                            context.loaderOverlay.hide();

                            if (!response.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login successful!')),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    sid: _sidController.text,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response.message)),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 13, 71, 161),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
