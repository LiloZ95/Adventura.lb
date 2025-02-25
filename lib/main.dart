import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/main_api.dart';
import 'package:adventura/Services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MainApi>(create: (_) => MainApi()), // ✅ Provide MainApi
        ChangeNotifierProvider<ApiService>(create: (_) => ApiService()), // ✅ Provide ApiService
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
          return mainApi.initialScreen ?? Scaffold(body: Center(child: CircularProgressIndicator())); // ✅ Prevents null error
        },
      ),
    );
  }
}