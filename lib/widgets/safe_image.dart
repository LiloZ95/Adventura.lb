import 'package:flutter/material.dart';

Widget safeImage(String? url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url == null || url.isEmpty) {
    return _fallbackImage(width, height);
  }

  if (url.startsWith("http")) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallbackImage(width, height),
    );
  }

  // If it's a local asset (like .jpg/.png), try to show it
  if (url.endsWith(".jpg") || url.endsWith(".png")) {
    return Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
    );
  }

  return _fallbackImage(width, height);
}


Widget _fallbackImage(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
    child: const Center(
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 48,
      ),
    ),
  );
}
