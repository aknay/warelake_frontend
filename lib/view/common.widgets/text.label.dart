import 'package:flutter/material.dart';

class TextLabel extends StatelessWidget {
  final Color color;
  final String text;
  const TextLabel({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            color: color.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
              child: Text(text, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color)),
            )));
  }
}
