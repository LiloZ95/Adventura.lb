import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:adventura/Services/reel_service.dart';
import 'package:adventura/utils/snackbars.dart';

class UploadReelPgPage extends StatefulWidget {
  final VoidCallback? onUploadComplete;

  UploadReelPgPage({this.onUploadComplete});

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
      reelsRefreshNotifier.value++;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${result["error"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Colors.blue;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text("Upload Reel"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Box
            GestureDetector(
              onTap: () async {
                final picked =
                    await _picker.pickVideo(source: ImageSource.gallery);
                if (picked != null) setState(() => _selectedVideo = picked);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 220,
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.grey[850] : primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        _selectedVideo == null ? Colors.blueGrey : Colors.green,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: _selectedVideo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_rounded,
                                size: 48, color: primaryBlue),
                            SizedBox(height: 8),
                            Text("Tap to upload video",
                                style: TextStyle(color: Colors.black54)),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 42, color: Colors.green),
                            SizedBox(height: 4),
                            Text("Video selected"),
                            SizedBox(height: 4),
                            Text(
                              _selectedVideo!.name,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Organizer Field
            TextField(
              controller: _organizerController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Organizer",
                floatingLabelStyle: TextStyle(color: primaryBlue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.person, color: primaryBlue),
              ),
            ),

            SizedBox(height: 20),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Write something about the reel...",
                floatingLabelStyle: TextStyle(color: primaryBlue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.edit, color: primaryBlue),
              ),
            ),

            SizedBox(height: 32),

            // Upload Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              onPressed: _handleUpload,
              icon: Icon(Icons.cloud_upload_rounded),
              label: Text("Upload Reel",
                  style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
