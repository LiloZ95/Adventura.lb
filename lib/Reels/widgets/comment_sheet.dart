import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:adventura/config.dart';

class CommentSheet extends StatefulWidget {
  final int reelId;
  CommentSheet({required this.reelId});

  @override
  _CommentSheetState createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/reels/${widget.reelId}/comments'));
      if (response.statusCode == 200) {
        setState(() {
          comments = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final accessToken = Hive.box('authBox').get("accessToken");

    final response = await http.post(
      Uri.parse('$baseUrl/reels/${widget.reelId}/comments'),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      _loadComments(); // reload
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                      ? Center(
                          child: Text("No comments",
                              style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: comments.length,
                          itemBuilder: (_, index) {
                            final c = comments[index];
                            return ListTile(
                              title: Text(
                                  "${c['user']['first_name']} ${c['user']['last_name']}",
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text(c['text'],
                                  style: TextStyle(color: Colors.white70)),
                            );
                          },
                        ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _postComment,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
