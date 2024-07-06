import 'package:flutter/material.dart';

class ExpiredItemLabel extends StatelessWidget {
  final String text;

  const ExpiredItemLabel(this.text, { super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.redAccent),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ),
      ),
    );
  }
}