import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UploadReelPage extends StatefulWidget {
  @override
  _UploadReelPageState createState() => _UploadReelPageState();
}

class _UploadReelPageState extends State<UploadReelPage> {
  XFile? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _organizerNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  Future<void> _loadOrganizerName() async {
    try {
      final authBox = Hive.box('authBox');
      final firstName = authBox.get("firstName", defaultValue: "");
      final lastName = authBox.get("lastName", defaultValue: "");

      setState(() {
        _organizerNameController.text = "$firstName $lastName";
      });
    } catch (e) {
      print("Failed to load organizer name: $e");
    }
  }

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
        SnackBar(
            content: Text("Please select a video and enter a description.")),
      );
      return;
    }

    try {
      // final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // final storageRef =
      //     FirebaseStorage.instance.ref().child('reels/$fileName.mp4');

      // final downloadUrl = await storageRef.getDownloadURL();

      // await FirebaseFirestore.instance.collection('reels').add({
      //   'videoUrl': downloadUrl,
      //   'description': _descriptionController.text.trim(),
      //   'organizer': _organizerNameController.text.trim(),
      //   'category': _selectedCategory,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });

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
  void initState() {
    super.initState();
    _loadOrganizerName();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Upload Reel"),
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎥 Custom Video Picker Container
            GestureDetector(
                onTap: _pickVideo,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedVideo == null ? Colors.grey : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _selectedVideo == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library,
                                  size: 40, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text("Tap to add a video",
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.grey[700])),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 36, color: Colors.green),
                              SizedBox(height: 8),
                              Text(
                                "Video selected",
                                style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.green),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _selectedVideo!.name,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.grey[800]),
                              ),
                            ],
                          ),
                  ),
                )),

            SizedBox(height: 24),
            TextField(
              controller: _organizerNameController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Organizer",
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                prefixIcon: Icon(Icons.person, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),

            SizedBox(height: 16),
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write something about the reel...",
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 16),
            Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text("Select a category"),
              isExpanded: true,
              items: [
                "Sea Trips",
                "Festivals",
                "Picnic",
                "Paragliding",
                "Sunsets",
                "Tours",
                "Car Events",
                "Hikes",
                "Snow Skiing",
                "Boats",
                "Jetski",
                "Museums"
              ]
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),

            SizedBox(height: 32),
            Center(
                child: ElevatedButton.icon(
              onPressed: _uploadReel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF007AFF),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.cloud_upload, color: Colors.white),
              label: Text("Upload Reel", style: TextStyle(color: Colors.white)),
            ))
          ],
        ),
      ),
    );
  }
}
