import 'dart:convert';
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

  static Future<String?> submitFullProviderRequest({
    required String businessName,
    required String description,
    required String businessEmail,
    required String businessCity,
    required XFile logoFile,
    String? instagram,
    String? tiktok,
    String? facebook,
  }) async {
    try {
      final flowBox = await Hive.openBox('providerFlow');
      final authBox = await Hive.openBox('authBox');

      final userId = authBox.get("userId");
      final birthDate =
          "${flowBox.get("selectedYear")}-${flowBox.get("selectedMonth")}-${flowBox.get("selectedDay")}";
      final city = flowBox.get("selectedCity");
      final address = flowBox.get("address");

      // Step 1: Submit provider request
      final response = await http.post(
        Uri.parse("$baseUrl/api/provider-request"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "birth_date": birthDate,
          "city": city,
          "address": address,
          // Optionally: Add business info to DB later
        }),
      );

      if (response.statusCode != 201) {
        return "Failed to create provider request: ${response.body}";
      }

      // Step 2: Upload documents
      final govIdPath = flowBox.get("govIdPath");
      final selfiePath = flowBox.get("selfiePath");
      final certPath = flowBox.get("certificatePath");

      final uploadError = await uploadProviderDocuments(
        govId: XFile(govIdPath),
        selfie: XFile(selfiePath),
        certificate: certPath != null ? XFile(certPath) : null,
      );

      if (uploadError != null) {
        return "Document upload failed: $uploadError";
      }

      // Optionally Step 3: Save business info & social links somewhere too

      return null; // success
    } catch (e) {
      return "Submission failed: $e";
    }
  }
}
