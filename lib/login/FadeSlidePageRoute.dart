import 'package:flutter/material.dart';

class CinematicPageRoute extends PageRouteBuilder {
  final Widget page;

  CinematicPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 550),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutQuart,
              reverseCurve: Curves.easeInOutCubic,
            );

            return AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final scale = Tween<double>(begin: 0.96, end: 1.0).evaluate(curved);
                final opacity = Tween<double>(begin: 0.0, end: 1.0).evaluate(curved);
                final elevation = Tween<double>(begin: 16.0, end: 0.0).evaluate(curved);

                return Transform(
                  transform: Matrix4.identity()
                    ..scale(scale)
                    ..setEntry(3, 2, 0.001), // subtle depth
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: opacity,
                    child: Material(
                      elevation: elevation,
                      color: Colors.transparent,
                      child: child,
                    ),
                  ),
                );
              },
            );
          },
        );
}
