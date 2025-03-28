import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final List<String> features;
  final List<Map<String, String>> tripPlan;

  const PreviewPage({
    Key? key,
    required this.title,
    required this.description,
    required this.location,
    required this.features,
    required this.tripPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle('📌 Title'),
            Text(title),
            _sectionTitle('📝 Description'),
            Text(description),
            _sectionTitle('📍 Location'),
            Text(location),
            _sectionTitle('🎯 Features'),
            Wrap(
              spacing: 8,
              children: features.map((f) => Chip(label: Text(f))).toList(),
            ),
            _sectionTitle('📅 Trip Plan'),
            ...tripPlan.map((e) => ListTile(
                  title: Text(e['time'] ?? ''),
                  subtitle: Text(e['description'] ?? ''),
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'poppins',
          ),
        ),
      );
}
