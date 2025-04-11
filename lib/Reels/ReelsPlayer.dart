import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';

class Comment {
  final String userName;
  final String text;
  final DateTime timestamp;
  final Uint8List? profileImageBytes;

  Comment({
    required this.userName,
    required this.text,
    required this.timestamp,
    this.profileImageBytes,
  });
}

class ReelsPlayer extends StatefulWidget {
  @override
  _ReelsPlayerState createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  
  final List<String> videoUrls = [
    'https://firebasestorage.googleapis.com/v0/b/adevnutralb.firebasestorage.app/o/natrue%20videos%2FSnapchat-125401604.mp4?alt=media&token=a5df6988-6a24-45bf-89fc-eaac4d496661',
    'https://firebasestorage.googleapis.com/v0/b/adevnutralb.firebasestorage.app/o/natrue%20videos%2FSnapchat-142994796.mp4?alt=media&token=2fac414f-a673-42fb-bbcf-11a100f29d79',
    'https://firebasestorage.googleapis.com/v0/b/adevnutralb.firebasestorage.app/o/natrue%20videos%2FSnapchat-75340133.mp4?alt=media&token=1a458e2e-e4a8-48c8-a51f-ded337e26fed',
    'https://firebasestorage.googleapis.com/v0/b/adevnutralb.firebasestorage.app/o/natrue%20videos%2FSnapchat-91757244.mp4?alt=media&token=f0dd1932-9c6b-468e-888c-76361641ae40',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return ReelVideoItem(videoUrl: videoUrls[index]);
        },
      ),
    );
  }
}

class ReelVideoItem extends StatefulWidget {
  final String videoUrl;

  ReelVideoItem({required this.videoUrl});

  @override
  _ReelVideoItemState createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<ReelVideoItem> {
  late VideoPlayerController _controller;
  TextEditingController commentController = TextEditingController();
  bool isVisible = false;
  bool isLiked = false;
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    setState(() {
      isVisible = info.visibleFraction > 0.8;
    });

    if (isVisible && _controller.value.isInitialized) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  void _openCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: comments.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: comment.profileImageBytes != null
                                ? MemoryImage(comment.profileImageBytes!)
                                : AssetImage('assets/default_avatar.png') as ImageProvider,
                            radius: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(comment.userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    SizedBox(width: 10),
                                    Text(
                                      TimeOfDay.fromDateTime(comment.timestamp).format(context),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white60),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(comment.text,
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              TextField(
                controller: commentController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final box = Hive.box('authBox');
                      final String firstName = box.get('firstName') ?? 'User';
                      final String lastName = box.get('lastName') ?? '';
                      final Uint8List? profileBytes = box.get('profileImageBytes_userId');

                      if (commentController.text.trim().isNotEmpty) {
                        setState(() {
                          comments.add(Comment(
                            userName: "$firstName $lastName",
                            text: commentController.text.trim(),
                            timestamp: DateTime.now(),
                            profileImageBytes: profileBytes,
                          ));
                        });
                        commentController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Center(child: CircularProgressIndicator()),

          // Right-side actions
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 28),
                IconButton(
                  onPressed: _openCommentSheet,
                  icon: Icon(Icons.comment, color: Colors.white, size: 32),
                ),
                SizedBox(height: 28),
                IconButton(
                  onPressed: () {
                    Share.share('Check out this event! https://adventura.lb/events/123');
                  },
                  icon: Icon(Icons.send, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          // Left-side organizer name
         Positioned(
  bottom: 20,
  left: 16,
  right: 20,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '@organizer_name',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[850], // dark grey background
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            hintStyle: TextStyle(color: Colors.white70),
            border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
               borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ],
  ),
),
// Top Gradient Fade
Positioned(
  top: 0,
  left: 0,
  right: 0,
  height: 100,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.transparent,
        ],
      ),
    ),
  ),
),

// Bottom Gradient Fade
Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  height: 120,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.transparent,
        ],
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
