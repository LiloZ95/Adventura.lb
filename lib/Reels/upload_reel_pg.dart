import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:adventura/Services/reel_service.dart'; // 👈 Import the logic
import 'package:adventura/utils/snackbars.dart'; // Optional helper if you have it

class UploadReelPgPage extends StatefulWidget {
  @override
  _UploadReelPgPageState createState() => _UploadReelPgPageState();
}

class _UploadReelPgPageState extends State<UploadReelPgPage> {
  XFile? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrganizerName();
  }

  Future<void> _loadOrganizerName() async {
    final authBox = Hive.box('authBox');
    final firstName = authBox.get("firstName", defaultValue: "");
    final lastName = authBox.get("lastName", defaultValue: "");
    _organizerController.text = "$firstName $lastName";
  }

  void _handleUpload() async {
    final result = await ReelService.uploadReelToServer(
      videoFile: _selectedVideo,
      description: _descriptionController.text.trim(),
    );

    if (result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${result["message"]}")),
      );
      setState(() {
        _selectedVideo = null;
        _descriptionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${result["error"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("Upload Reel")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: () async {
              final picked = await _picker.pickVideo(source: ImageSource.gallery);
              if (picked != null) setState(() => _selectedVideo = picked);
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedVideo == null ? Colors.grey : Colors.green,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: _selectedVideo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to add a video"),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 36),
                          Text("Video selected"),
                          SizedBox(height: 4),
                          Text(_selectedVideo!.name, style: TextStyle(fontSize: 12)),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _organizerController,
            readOnly: true,
            decoration: InputDecoration(labelText: "Organizer"),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write something about the reel...",
              labelText: "Description",
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleUpload,
            icon: Icon(Icons.cloud_upload),
            label: Text("Upload Reel"),
          ),
        ]),
      ),
    );
  }
}
