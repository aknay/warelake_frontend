import 'package:flutter/material.dart';

class YesOrNoDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool showWarning;
  final String actionWord;

  const YesOrNoDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionWord,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconOrEmptyWidget = showWarning
        ? const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.warning,
              color: Colors.red,
              size: 32,
            ),
          )
        : const SizedBox.shrink();
    return AlertDialog(
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("CANCLE")),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child:  Text(actionWord.toUpperCase())),
      ],
      title: Row(
        children: [
          iconOrEmptyWidget,
          Text(title),
        ],
      ),
      content: Text(content),
    );
  }
}
