import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoteTextFormField extends ConsumerWidget {
  const NoteTextFormField({super.key, required this.onValueChanged});
  final void Function(String dateTime) onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      onChanged: onValueChanged,
      decoration: InputDecoration(
        hintText: 'Note',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: FaIcon(FontAwesomeIcons.noteSticky, color: Colors.white),
        ),
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        border: const OutlineInputBorder(),
        
      ),
    );
  }
}
