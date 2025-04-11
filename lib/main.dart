import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventura/main_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully");
  } catch (e) {
    print("⚠️ Could not load .env file: $e");
  }

  // ✅ Initialize Hive for both web & mobile
  await Hive.initFlutter();
  await Hive.openBox('authBox'); // Open Hive storage

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainApi()),
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
