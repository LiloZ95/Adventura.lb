import 'dart:io';
import 'package:adventura/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

class ProviderService {
  static Future<String?> uploadProviderDocuments({
    required XFile govId,
    required XFile selfie,
    XFile? certificate,
  }) async {
    try {
      final box = await Hive.openBox('authBox');
      final userId = box.get("userId");

      var uri = Uri.parse("$baseUrl/api/provider-request/upload-documents");
      var request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId.toString();

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'gov_id',
          await govId.readAsBytes(),
          filename: "gov_id.jpg",
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'gov_id',
          govId.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'selfie',
          await selfie.readAsBytes(),
          filename: "selfie.jpg",
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'selfie',
          selfie.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      if (certificate != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'certificate',
          certificate.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return null; // No error
      } else {
        return responseBody; // Error message
      }
    } catch (e) {
      return "Upload failed: $e";
    }
  }
}
