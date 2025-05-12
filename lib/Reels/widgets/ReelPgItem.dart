import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:adventura/services/reel_service.dart';
import 'package:hive/hive.dart';

class ReelPgItem extends StatefulWidget {
  final Map<String, dynamic> reel;

  const ReelPgItem({Key? key, required this.reel}) : super(key: key);

  @override
  State<ReelPgItem> createState() => _ReelPgItemState();
}

class _ReelPgItemState extends State<ReelPgItem> {
  late VideoPlayerController _controller;
  bool isMuted = true;
  bool isLiked = false;
  bool showMuteIcon = false;
  bool showHeart = false;
  int likeCount = 0;
  Timer? _muteIconTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadLikeState();
  }

  void _initPlayer() {
    _controller = VideoPlayerController.network(widget.reel["video_url"])
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
      });
  }

  Future<void> _loadLikeState() async {
    final count = await ReelService.getReelLikes(widget.reel["reel_id"]);
    final userId = Hive.box('authBox').get("userId");

    final liked = await ReelService.didUserLikeReel(
      userId: userId,
      reelId: widget.reel["reel_id"],
    );

    setState(() {
      likeCount = count;
      isLiked = liked;
    });
  }

  Future<void> _toggleLike() async {
    final result = await ReelService.toggleReelLike(widget.reel["reel_id"]);
    if (result["success"]) {
      setState(() {
        isLiked = result["liked"];
        likeCount += isLiked ? 1 : -1;
        showHeart = true;
      });
      Future.delayed(Duration(milliseconds: 700), () {
        if (mounted) setState(() => showHeart = false);
      });
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _controller.setVolume(isMuted ? 0.0 : 1.0);
      showMuteIcon = true;
    });
    _muteIconTimer?.cancel();
    _muteIconTimer = Timer(Duration(seconds: 1), () {
      if (mounted) setState(() => showMuteIcon = false);
    });
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _showComments() {
    ReelService.openCommentsSheet(
      context,
      reelId: widget.reel["reel_id"],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _muteIconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMute,
      onDoubleTap: _toggleLike,
      onLongPress: _togglePlay,
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

          if (showMuteIcon)
            Center(
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                size: 80,
                color: Colors.white70,
              ),
            ),

          if (showHeart)
            Center(
              child: Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 100,
              ),
            ),

          Positioned(
            bottom: 70,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${widget.reel['provider']?['business_name'] ?? 'unknown'}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  widget.reel["description"] ?? '',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 60,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleLike,
                ),
                Text("$likeCount", style: TextStyle(color: Colors.white)),
                SizedBox(height: 28),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white),
                  onPressed: _showComments,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
