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
    const beginOffset = Offset(1.0, 0.0); 
    const endOffset = Offset.zero;

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic, 
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}
