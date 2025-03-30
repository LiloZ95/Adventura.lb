import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsPlayer extends StatefulWidget {
  @override
  _ReelsPlayerState createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  final List<String> videoAssets = [
    'assets/videos/Snapchat-75340133.mp4',
    'assets/videos/Snapchat-91757244.mp4',
    'assets/videos/Snapchat-125401604.mp4',
    'assets/videos/Snapchat-125401604.mp4',
  ];

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
  bool isVisible = false;
  bool isLiked = false;

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
            bottom: 20,
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
                Icon(Icons.comment, color: Colors.white, size: 32),
                SizedBox(height: 28),
                Icon(Icons.send, color: Colors.white, size: 32),
                SizedBox(height: 100),
              ],
            ),
          ),

          // Left-side organizer name
         Positioned(
  bottom: 20,
  left: 16,
  right: 16,
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
        ],
      ),
    );
  }
}
