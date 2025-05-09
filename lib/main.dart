import 'package:adventura/userinformation/widgets/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventura/main_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ✅ NEW import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully");
  } catch (e) {
    print("⚠️ Could not load .env file: $e");
  }

  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('chatMessages');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseFirestore.instance.collection('reels').get();
  } catch (e) {
    print('🔥 Firestore error: $e');
  }

  final themeController = ThemeController(); // loads theme from Hive

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainApi()),
        ChangeNotifierProvider(
            create: (_) => themeController), // ✅ Use the same instance
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MainApi, ThemeController>(
      builder: (context, mainApi, themeController, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor:
                Color(0xFFF6F6F6), // match your app's light background
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor:
                Color(0xFF121212), // match your dark background
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),

          themeMode: themeController.currentTheme, // ✅ Control theme globally
          home: mainApi.initialScreen,
        );
      },
    );
  }
}
