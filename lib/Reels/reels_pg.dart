import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adventura/services/reel_service.dart';

import 'widgets/ReelPgItem.dart';

class ReelsPgScreen extends StatefulWidget {
  final void Function(bool visible)? onScrollChanged;
  final VoidCallback? onBackToMainTab;

  const ReelsPgScreen({
    Key? key,
    this.onScrollChanged,
    this.onBackToMainTab,
  }) : super(key: key);

  @override
  _ReelsPgScreenState createState() => _ReelsPgScreenState();
}

class _ReelsPgScreenState extends State<ReelsPgScreen> {
  late Future<List<Map<String, dynamic>>> _reelsFuture;

  // Future<void> _refreshReels() async {
  //   final updatedReels = await ReelService.fetchReelsFromServer();
  //   setState(() {
  //     _reelsFuture = updatedReels;
  //   });
  // }

  @override
  void initState() {
    super.initState();

    _reelsFuture = ReelService.fetchReelsFromServer();

    reelsRefreshNotifier.addListener(() async {
      final updatedReels = await ReelService.fetchReelsFromServer();
      setState(() {
        _reelsFuture = Future.value(updatedReels);
      });
    });
  }

  @override
  void dispose() {
    reelsRefreshNotifier.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No reels found",
                    style: TextStyle(color: Colors.white)));
          }

          final reels = snapshot.data!;

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (widget.onScrollChanged != null) {
                widget.onScrollChanged!(
                    notification.direction == ScrollDirection.forward);
              }
              return true;
            },
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: reels.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ReelPgItem(reel: reels[index]),
                    // 👇 Back button overlaid
                    Positioned(
                      top: 40,
                      left: 16,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: widget.onBackToMainTab,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
