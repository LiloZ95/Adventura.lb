import 'package:flutter/material.dart';

class SecurityPageRoute extends PageRouteBuilder {
  final Widget child;

  SecurityPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(
                opacity: curve,
                child: child,
              ),
            );
          },
        );
}
