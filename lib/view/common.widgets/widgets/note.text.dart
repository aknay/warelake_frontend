import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class NoteText extends StatelessWidget {
  final Option<String> notes;
  const NoteText(
    this.notes, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final noteWidget = notes.fold(() => const SizedBox.shrink(), (value) => Text(value));

    return Row(
      children: [const Text('Notes:'), gapW8, noteWidget],
    );
  }
}
