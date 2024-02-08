import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/view/onboarding/currency.selection/currency.selection.page.dart';

final _currencyProvider = StateProvider<Option<Currency>>(
  (ref) {
    return const None();
  },
);

class CurrencySelectionWidget extends ConsumerWidget {
  const CurrencySelectionWidget({super.key, required this.onValueChanged});
  final void Function(Option<Currency> currency) onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyOrNone = ref.watch(_currencyProvider);

    final currencyText = currencyOrNone.fold(() => "Select a currency", (r) => "${r.code} - ${r.name}");

    return GestureDetector(
      onTap: () async {
        Currency? currencyCode =
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencySelectionPage()));
        if (currencyCode != null) {
          ref.read(_currencyProvider.notifier).state = optionOf(currencyCode);
          onValueChanged(optionOf(currencyCode));
        }
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
