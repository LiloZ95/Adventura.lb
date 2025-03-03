import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/main_api.dart';
import 'package:adventura/Main screen components/MainScreen.dart';
import 'package:adventura/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => MainApi()), // ✅ Register MainApi here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<MainApi>(
        builder: (context, mainApi, child) {
          return mainApi
              .initialScreen; // ✅ Redirect to correct screen based on login status
        },
      ),
    );
  }
}
