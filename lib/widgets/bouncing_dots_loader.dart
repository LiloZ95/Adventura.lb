import 'package:flutter/material.dart';

class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const BouncingDotsLoader({
    Key? key,
    this.color = Colors.blue,
    this.size = 14.0,
  }) : super(key: key);

  @override
  _BouncingDotsLoaderState createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _bounceAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _bounceAnimations = List.generate(3, (index) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: -14.0, end: 0.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _fadeAnimations = List.generate(3, (index) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimations[index].value),
          child: Opacity(
            opacity: _fadeAnimations[index].value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size * 3,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _buildDot(index)),
        ),
      ),
    );
  }
}
