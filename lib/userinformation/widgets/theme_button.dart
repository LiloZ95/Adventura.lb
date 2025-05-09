// ignore_for_file: unused_field

import 'dart:ui';

import 'package:flutter/material.dart';

class AppearanceFAB extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const AppearanceFAB({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  State<AppearanceFAB> createState() => _AppearanceFABState();
}

class _AppearanceFABState extends State<AppearanceFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset _center = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startReveal(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      _center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    });

    _controller.forward(from: 0).then((_) {
      widget.onToggle(); // Switch theme
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.isDarkMode ? Colors.black87 : Colors.blue,
      onPressed: () => _startReveal(context),
      child: Icon(
        widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.white,
      ),
    );
  }
}
