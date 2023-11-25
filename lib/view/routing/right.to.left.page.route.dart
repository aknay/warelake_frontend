import 'package:flutter/material.dart';

class RightToLeftPageRoute<T> extends MaterialPageRoute<T> {
  RightToLeftPageRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const Offset begin = Offset(1.0, 0.0); // Start off-screen to the right
    const Offset end = Offset.zero;
    const Curve curve = Curves.easeOut;

    var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve)); // Customize the animation curve

    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}