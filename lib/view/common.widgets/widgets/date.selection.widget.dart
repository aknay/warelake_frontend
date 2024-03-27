import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _dateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());

class DateSelectionWidget extends ConsumerWidget {
  const DateSelectionWidget({super.key, required this.onValueChanged});
  final void Function(DateTime dateTime) onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = ref.watch(_dateProvider);

    final currencyText = _formattedDate(dateTime);

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final DateTime? picked = await showDatePicker(
            context: context, initialDate: now, firstDate: DateTime(now.year, now.month - 6, now.day), lastDate: now);
        if (picked != null) {
          ref.read(_dateProvider.notifier).state = picked;
          onValueChanged(picked);
        }
      },
      child: TextFormField(
        enabled: false, // Make it non-editable
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, top: 8),
            child: FaIcon(FontAwesomeIcons.calendar, color: Colors.white),
          ),
          labelText: currencyText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String _formattedDate(DateTime dt) {
    return DateFormat('d MMM yyyy').format(dt);
  }
}
