import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/view/bill.account.selection/bill.account.selection.page.dart';

final _billAccountProvider = StateProvider<Option<BillAccount>>(
  (ref) {
    return const None();
  },
);

class BillAccountSelectionWidget extends ConsumerWidget {
  const BillAccountSelectionWidget({super.key, required this.onValueChanged});
  final void Function(Option<BillAccount> billAccount) onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyOrNone = ref.watch(_billAccountProvider);

    final currencyText = currencyOrNone.fold(() => "Select a bill account", (r) => r.name);

    return GestureDetector(
      onTap: () async {
        BillAccount? billAccount =
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const BillAccountSelectionPage()));
        if (billAccount != null) {
          ref.read(_billAccountProvider.notifier).state = optionOf(billAccount);
          onValueChanged(optionOf(billAccount));
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
