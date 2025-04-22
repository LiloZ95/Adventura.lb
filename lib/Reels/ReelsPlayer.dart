import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

class ReelsPlayer extends StatelessWidget {
  final void Function(bool visible)? onScrollChanged;
  final VoidCallback? onBackToMainTab;

  ReelsPlayer({
    Key? key,
    this.onScrollChanged,
    this.onBackToMainTab,
  }) : super(key: key);

  final Stream<QuerySnapshot> _reelsStream = FirebaseFirestore.instance
      .collection('reels')
      .orderBy('timestamp', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: _reelsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("No reels found",
                    style: TextStyle(color: Colors.white)));
          }

          final reels = snapshot.data!.docs;

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              return ReelVideoItem(
                videoUrl: reel['videoUrl'],
                organizer: reel['organizer'] ?? 'Unknown',
                description: reel['description'] ?? '',
                onBack: onBackToMainTab,
              );
            },
          );
        },
      ),
    );
  }
}

class ReelVideoItem extends StatefulWidget {
  final String videoUrl;
  final String organizer;
  final String description;
  final VoidCallback? onBack;

  ReelVideoItem({
    required this.videoUrl,
    required this.organizer,
    required this.description,
    this.onBack,
  });

  @override
  _ReelVideoItemState createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<ReelVideoItem> {
  late VideoPlayerController _controller;
  TextEditingController commentController = TextEditingController();
  bool isVisible = false;
  bool isLiked = false;
  bool isMuted = false;
  bool showMuteIcon = false;
  bool showHeart = false;
  Offset heartPosition = Offset.zero;
  double heartScale = 1.0;

  int likeCount = 125;
  int commentCount = 37;
  List<Comment> comments = [];

  @override
  Future<void> _checkIfLiked() async {
    final userBox = Hive.box('authBox');
    final userId = userBox.get('userId');
    if (userId == null) {
      print("🚨 No userId found in Hive!");
      return;
    }

    final safeDocId = '${widget.videoUrl}__$userId'.replaceAll('/', '_');

    final doc = await FirebaseFirestore.instance
        .collection('likes')
        .doc(safeDocId)
        .get();
    if (mounted) {
      setState(() {
        isLiked = doc.exists;
      });
    }
  }

  Future<void> _toggleLike() async {
    final userBox = Hive.box('authBox');
    final userId = userBox.get('userId');

    if (userId == null) {
      print("🚨 Cannot like: userId is null!");
      return;
    }

    // ✅ Create a safe Firestore document ID
    final safeDocId = '${widget.videoUrl}__$userId'.replaceAll('/', '_');

    final likeRef =
        FirebaseFirestore.instance.collection('likes').doc(safeDocId);

    if (isLiked) {
      await likeRef.delete();
      setState(() {
        isLiked = false;
        likeCount -= 1;
      });
    } else {
      await likeRef.set({
        'videoUrl': widget.videoUrl,
        'userId': userId,
        'timestamp': DateTime.now(),
      });
      setState(() {
        isLiked = true;
        likeCount += 1;
      });
    }
  }

  Future<void> _getLikeCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('videoUrl', isEqualTo: widget.videoUrl)
        .get();
    if (mounted) {
      setState(() {
        likeCount = snapshot.docs.length;
      });
    }
  }

  Future<void> _loadComments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('videoUrl', isEqualTo: widget.videoUrl)
          .orderBy('timestamp')
          .get();
      if (mounted) {
        setState(() {
          comments = snapshot.docs.map((doc) {
            return Comment(
              userName: doc['userName'],
              text: doc['text'],
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
              profileImageBytes: null, // use doc['profileImageUrl'] if needed
            );
          }).toList();
          commentCount = comments.length;
        });
      }
    } catch (e) {
      print("🔥 Failed to load comments: $e");
    }
  }

  Future<void> _postComment(
      String text, String userName, String profileImage) async {
    await FirebaseFirestore.instance.collection('comments').add({
      'videoUrl': widget.videoUrl,
      'userName': userName,
      'text': text,
      'timestamp': DateTime.now(),
      'profileImageUrl': profileImage,
    });
  }

  @override
  void initState() {
    super.initState();

    _getLikeCount();
    _checkIfLiked();
    _loadComments();

    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          _controller.setLooping(true);
          setState(() {});
        }
      }).catchError((e) {
        print('❌ Video failed to load: $e');
      });

    // _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    final shouldBeVisible = info.visibleFraction > 0.8;

    if (mounted) {
      setState(() {
        isVisible = shouldBeVisible;
      });
    }

    if (_controller.value.isInitialized) {
      if (shouldBeVisible) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  void _openCommentSheet() {
    _loadComments();
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
                                : AssetImage('assets/images/default_user.png')
                                    as ImageProvider,
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
                                      TimeOfDay.fromDateTime(comment.timestamp)
                                          .format(context),
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
                    onPressed: () async {
                      final box = Hive.box('authBox');
                      final String firstName = box.get('firstName') ?? 'User';
                      final String lastName = box.get('last_name') ?? '';
                      final Uint8List? profileBytes =
                          box.get('profileImageBytes_userId');
                      if (commentController.text.trim().isNotEmpty) {
                        final userBox = Hive.box('authBox');
                        final firstName = userBox.get('firstName') ?? 'Unknown';
                        final lastName = userBox.get('lastName') ?? '';
                        final profileImage =
                            userBox.get('profileImageUrl') ?? '';

                        final commentText = commentController.text.trim();

                        setState(() {
                          comments.add(Comment(
                            userName: "$firstName $lastName",
                            text: commentText,
                            timestamp: DateTime.now(),
                            profileImageBytes: null, // or your logic
                          ));
                          commentCount++;
                        });

                        await _postComment(
                            commentText, "$firstName $lastName", profileImage);
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
          AnimatedOpacity(
            opacity: showMuteIcon ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Center(
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white.withOpacity(0.9),
                size: 80,
              ),
            ),
          ),

          _controller.value.isInitialized
              ? GestureDetector(
                  behavior:
                      HitTestBehavior.opaque, // ✅ makes sure it receives taps
                  onTap: () {
                    debugPrint("🖐 onTap triggered!");

                    if (!_controller.value.isInitialized) return;

                    final newMuteState = !isMuted;

                    if (!kIsWeb) {
                      _controller.setVolume(newMuteState ? 0.0 : 1.0);
                      debugPrint(
                          "🔊 Volume set to ${newMuteState ? 0.0 : 1.0}");
                    } else {
                      debugPrint("⚠️ setVolume not supported on web.");
                    }

                    setState(() {
                      isMuted = newMuteState;
                      showMuteIcon = true;
                    });

                    Future.delayed(Duration(milliseconds: 1500), () {
                      if (mounted) {
                        setState(() {
                          showMuteIcon = false;
                        });
                      }
                    });
                  },
                  onDoubleTapDown: (details) {
                    setState(() {
                      heartPosition = details.globalPosition;
                    });
                  },
                  onDoubleTap: () {
                    _toggleLike();

                    setState(() {
                      showHeart = true;
                      heartScale = 1.5;
                    });

                    Future.delayed(Duration(milliseconds: 100), () {
                      if (mounted) {
                        setState(() {
                          heartScale = 1.0;
                        });
                      }
                    });

                    Future.delayed(Duration(milliseconds: 800), () {
                      if (mounted) {
                        setState(() {
                          showHeart = false;
                        });
                      }
                    });
                  },
                  onLongPressStart: (_) {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    }
                  },
                  onLongPressEnd: (_) {
                    if (!_controller.value.isPlaying && isVisible) {
                      _controller.play();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent, // ✅ ensure it catches taps
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator()),

          if (showHeart)
            Positioned(
              left: heartPosition.dx - 40,
              top: heartPosition.dy - 120,
              child: AnimatedOpacity(
                opacity: showHeart ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: heartScale,
                  duration: Duration(milliseconds: 150),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 90,
                  ),
                ),
              ),
            ),

          // Right-side actions
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
                Text('$likeCount', style: TextStyle(color: Colors.white)),
                SizedBox(height: 28),
                IconButton(
                  onPressed: _openCommentSheet,
                  icon: Icon(Icons.comment, color: Colors.white, size: 32),
                ),
                Text('$commentCount', style: TextStyle(color: Colors.white)),
                SizedBox(height: 28),
                IconButton(
                  onPressed: () {
                    Share.share(
                        'Check out this event! https://adventura.lb/events/123');
                  },
                  icon: Icon(Icons.send, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          // Organizer and description
          Positioned(
            bottom: 60,
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
                Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // 👇 Add this part here
                Container(
                  margin: EdgeInsets.only(top: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          final userBox = Hive.box('authBox');
                          final userId = userBox.get('userId');
                          final firstName =
                              userBox.get('firstName') ?? 'Unknown';
                          final lastName = userBox.get('lastName') ?? '';
                          final profileImage =
                              userBox.get('profileImageUrl') ?? '';

                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            await _postComment(
                                text, "$firstName $lastName", profileImage);
                            commentController.clear();
                            _loadComments(); // Refresh after posting
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  widget.onBack?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
