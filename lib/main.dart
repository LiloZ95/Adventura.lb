import 'package:adventura/userinformation/widgets/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventura/main_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainApi()),
        ChangeNotifierProvider(create: (context) => ThemeController()), // ✅ NEW provider
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
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.currentTheme, // ✅ Control theme globally
          home: mainApi.initialScreen,
        );
      },
    );
  }
}
