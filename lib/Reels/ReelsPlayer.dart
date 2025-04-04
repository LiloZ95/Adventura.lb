import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class ReelsPlayer extends StatefulWidget {
  @override
  _ReelsPlayerState createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  final List<String> videoAssets = [
    'assets/videos/Snapchat-75340133.mp4',
    'assets/videos/Snapchat-91757244.mp4',
    'assets/videos/Snapchat-125401604.mp4',
    'assets/videos/Snapchat-142994796.mp4',
  ];
  void shareToWhatsApp(String message) async {
  final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch WhatsApp';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoAssets.length,
        itemBuilder: (context, index) {
          return ReelVideoItem(videoUrl: videoAssets[index]);
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
  List<String> comments = []; 

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
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


  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
  fit: StackFit.expand,
  children: [
    // Video playback
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

          // Right-side vertical actions
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
  onPressed: () {
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
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: comments.map((comment) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(comment, style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )).toList(),
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
                      if (commentController.text.trim().isNotEmpty) {
                        setState(() {
                          comments.add(commentController.text.trim());
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
  },
  icon: Icon(Icons.comment, color: Colors.white, size: 32),
),
                SizedBox(height: 28),
            IconButton(
            onPressed: () {
              Share.share(
                'Check out this event! 🌍\nhttps://adventura.lb/events/123',
                subject: 'Adventure Invitation',
              );
            },
            icon: Icon(Icons.send, color: Colors.white, size: 30))],
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
