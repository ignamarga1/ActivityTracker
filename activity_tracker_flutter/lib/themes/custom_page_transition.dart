import 'package:flutter/material.dart';

class CustomPageTransition extends PageTransitionsBuilder {
  const CustomPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
