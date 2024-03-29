import 'package:flutter/material.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class NoteText extends StatelessWidget {
  final String? notes; 
  const NoteText(this.notes, {super.key, });

  @override
  Widget build(BuildContext context) {
    final noteWidget = notes == null ? const SizedBox.shrink() : Text(notes!);

    return  Row(
      children: [
        const Text('Notes:'), gapW8,
        noteWidget
      ],
    );
  }
}