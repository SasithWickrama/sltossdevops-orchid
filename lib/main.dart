import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:orchid_test_app/screens/splash_screen.dart';
import 'package:orchid_test_app/providers/login_provider.dart';
import 'package:orchid_test_app/providers/page_one_provider.dart';
import 'package:orchid_test_app/services/api_services.dart';
import 'package:orchid_test_app/controllers/login_controller.dart';
import 'package:orchid_test_app/providers/poles_provider.dart';

void main() {
  final apiService = ApiServices();
  final loginController = LoginController(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider(loginController)),
        ChangeNotifierProvider(
            create: (_) => PageOneProvider('initial_placeholder_ref')),
        ChangeNotifierProvider(create: (_) => PoleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
