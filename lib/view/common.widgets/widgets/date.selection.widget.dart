import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warelake/view/utils/date.time.utils.dart';

class DateSelectionWidget extends ConsumerStatefulWidget {
  const DateSelectionWidget(
      {super.key, this.initialDate = const None(), required this.onValueChanged, this.useLastDateAsToday = true});
  final void Function(DateTime dateTime) onValueChanged;
  final Option<DateTime> initialDate;
  final bool useLastDateAsToday;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends ConsumerState<DateSelectionWidget> {
  late final _dateProvider =
      StateProvider.autoDispose<DateTime>((ref) => widget.initialDate.fold(() => DateTime.now(), (x) => x));

  @override
  Widget build(BuildContext context) {
    final dateTime = ref.watch(_dateProvider);

    final formattedDateText = formatDate(dateTime);

    return GestureDetector(
      onTap: () async {
        final now = widget.initialDate.fold(() => DateTime.now(), (x) => x);
        final lastDate = widget.useLastDateAsToday == true ? now : DateTime(now.year + 20, now.month, now.day);
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(now.year, now.month - 6, now.day),
            lastDate: lastDate);
        if (picked != null) {
          ref.read(_dateProvider.notifier).state = picked;
          widget.onValueChanged(picked);
        }
      },
      child: TextFormField(
        enabled: false, // Make it non-editable
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, top: 12),
            child: FaIcon(FontAwesomeIcons.calendar, color: Colors.white),
          ),
          labelText: formattedDateText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
