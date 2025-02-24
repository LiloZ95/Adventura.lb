import 'package:adventura/intro/intro.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adventura/Services/api_service.dart'; // ✅ Import the API service
import 'package:provider/provider.dart';

void main() async {
  runApp(ChangeNotifierProvider(
      create: (context) => ApiService(),
      child: MyApp(),
    ),);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService apiService = ApiService();
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (!hasSeenOnboarding) {
    await prefs.setBool("hasSeenOnboarding", true);
    setState(() {
      _initialScreen = DynamicOnboarding(); // ✅ Show onboarding only once
    });
    return;
  }

    // Check if user is already logged in
    // bool isLoggedIn = await ApiService().isUserLoggedIn(); // ✅ Fixed to call ApiService
    setState(() {
      _initialScreen = isLoggedIn ? MainScreen() : LoginPage(); // Use MainScreen or LoginPage based on login status
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _initialScreen ??
          Scaffold(
         //   body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
