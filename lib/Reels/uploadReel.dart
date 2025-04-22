import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadReelPage extends StatefulWidget {
  @override
  _UploadReelPageState createState() => _UploadReelPageState();
}

class _UploadReelPageState extends State<UploadReelPage> {
  XFile? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = pickedFile;
      });
    }
  }

  Future<void> _uploadReel() async {
    if (_selectedVideo == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a video and enter a description.")),
      );
      return;
    }

    try {
      final file = File(_selectedVideo!.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('reels/$fileName.mp4');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('reels').add({
        'videoUrl': downloadUrl,
        'description': _descriptionController.text.trim(),
        'organizer': _organizerNameController.text.trim(),
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Reel uploaded successfully")),
      );

      setState(() {
        _selectedVideo = null;
        _organizerNameController.clear();
        _descriptionController.clear();
        _selectedCategory = null;
      });
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Reel"),
        backgroundColor: Color.fromRGBO(0, 122, 255, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎥 Custom Video Picker Container
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: _selectedVideo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library, size: 40, color: Colors.grey[600]),
                            SizedBox(height: 8),
                            Text("Add Video", style: TextStyle(color: Colors.grey[700])),
                            SizedBox(height: 8),
                            Text(
                              "Video: 0/1 • First video will be shown",
                              style: TextStyle(fontSize: 12, color: Colors.blue),
                            )
                          ],
                        )
                      : Text(
                          "Video selected: ${_selectedVideo!.name}",
                          style: TextStyle(color: Colors.green),
                        ),
                ),
              ),
            ),

            SizedBox(height: 24),
            Text("Organizer Name", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _organizerNameController,
              decoration: InputDecoration(hintText: "Enter your name"),
            ),

            SizedBox(height: 16),
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(hintText: "Write something..."),
            ),

            SizedBox(height: 16),
            Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: Text("Select a category"),
              isExpanded: true,
              items: [
                "Sea Trips", "Festivals", "Picnic", "Paragliding",
                "Sunsets", "Tours", "Car Events", "Hikes",
                "Snow Skiing", "Boats", "Jetski", "Museums",
              ].map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  )).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),

            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _uploadReel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 122, 255, 1),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: Text("Upload Reel",style: TextStyle(color:Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
