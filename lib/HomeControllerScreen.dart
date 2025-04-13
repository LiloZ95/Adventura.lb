import 'dart:async';
import 'dart:ui';

import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/Reels/ReelsPlayer.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'widgets/bottom_nav_bar.dart';

class HomeControllerScreen extends StatefulWidget {
  @override
  _HomeControllerScreenState createState() => _HomeControllerScreenState();
}

class _HomeControllerScreenState extends State<HomeControllerScreen> with TickerProviderStateMixin {

  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;
  Timer? _scrollStopTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    _fadeController.reset();
    setState(() {
      _selectedIndex = index;
    });
    _fadeController.forward();
  }

  void _handleScrollChanged(bool visible) {
    if (_isNavBarVisible != visible) {
      setState(() {
        _isNavBarVisible = visible;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      // Cancel any running timer
      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
      } else if (direction == ScrollDirection.forward) {
        if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
      }

      // Restart the timer on scroll
      _scrollStopTimer = Timer(Duration(milliseconds: 300), () {
        if (!_isNavBarVisible) {
          setState(() => _isNavBarVisible = true); // Reset after user stops
        }
      });
    });

    _screens = [
      MainScreen(onScrollChanged: _handleScrollChanged),
      SearchScreen(onScrollChanged: _handleScrollChanged),
      MyBookingsPage(onScrollChanged: _handleScrollChanged),
      Placeholder(),
      ReelsPlayer(onScrollChanged: _handleScrollChanged),
    ];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollStopTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Replace AnimatedSwitcher with IndexedStack to preserve state of screens
          FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),

          // Floating Nav Bar on top with full transparency
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 16,
            right: 16,
            bottom: 20,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _isNavBarVisible ? 1.0 : 0.6,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isNavBarVisible ? 65 : 55,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: _isNavBarVisible ? 0 : 6,
                        sigmaY: _isNavBarVisible ? 0 : 6),
                    child: BottomNavBar(
                      selectedIndex: _selectedIndex,
                      onTap: _onTabTapped,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
