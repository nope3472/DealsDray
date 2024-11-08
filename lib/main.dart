
import 'package:dealsdray/home.dart';
import 'package:dealsdray/login.dart';
import 'package:dealsdray/splashscreen.dart';
import 'package:dealsdray/verification.dart';
import 'package:flutter/material.dart';


void main() {
  // Add error handling for Flutter errors
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  SplashScreen(),
    );
  }
}
