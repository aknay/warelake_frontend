import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/view/onboarding/time.zone/time.zone.selection.screen.dart';

final _currencyProvider = StateProvider<Option<Currency>>(
  (ref) {
    return const None();
  },
);

class TimeZoneSelectionWidget extends ConsumerWidget {
  const TimeZoneSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyOrNone = ref.watch(_currencyProvider);

    final currencyText = currencyOrNone.fold(() => "Select a Time Zone", (r) => "${r.code} - ${r.name}");

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeZoneScreen()));
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
