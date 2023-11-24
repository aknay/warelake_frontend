import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/onboarding/time.zone/time.zone.helper.dart';
import 'package:inventory_frontend/view/onboarding/time.zone/time.zone.selection.screen.dart';
import 'package:timezone/timezone.dart' as tz;

final _timeZoneLocationProvider = StateProvider<Option<tz.Location>>(
  (ref) {
    return const None();
  },
);

class TimeZoneSelectionWidget extends ConsumerWidget {
  const TimeZoneSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locaitonOrNone = ref.watch(_timeZoneLocationProvider);

    final currencyText = locaitonOrNone.fold(() => "Select a Time Zone", (r) => getTimeZoneString(r));

    return GestureDetector(
      onTap: () async {
        tz.Location? location =
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeZoneScreen()));
        ref.read(_timeZoneLocationProvider.notifier).state = optionOf(location);
      },
      child: TextFormField(
        enabled: false, // Make it non-editable
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.currency_exchange_outlined, color: Colors.white),
          labelText: currencyText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
