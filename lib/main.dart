import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventura/main_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adventura/Main screen components/MainScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Detect if running on Web
import 'dart:io'; // For platform detection (only for mobile)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive (Handle Web & Mobile separately)
  if (kIsWeb) {
    await Hive.initFlutter(); // Web does not need a directory
  } else {
    await Hive.initFlutter();
  }
  await Hive.openBox('authBox'); // Open Hive storage

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
