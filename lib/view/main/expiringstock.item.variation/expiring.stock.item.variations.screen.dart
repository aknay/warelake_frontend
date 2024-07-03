import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warelake/view/main/expiringstock.item.variation/async.expired.stock.item.variation.list.view.dart';
import 'package:warelake/view/utils/date.time.utils.dart';

final expiringDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.now().add(const Duration(days: 30));
});

class ExpiringStockItemVariationsScreen extends ConsumerWidget {
  const ExpiringStockItemVariationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = ref.watch(expiringDateProvider);
    final formattedDateText = formatExpiryDate(dateTime);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Expiry Check"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 200,
                            // color: Colors.red,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                const Text('Expiring Date'),
                                ElevatedButton(
                                  child: const Text('In 1 month'),
                                  onPressed: () {
                                    ref
                                            .read(expiringDateProvider.notifier)
                                            .state =
                                        DateTime.now()
                                            .add(const Duration(days: 30));

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('In 6 months'),
                                  onPressed: () {
                                    ref
                                            .read(expiringDateProvider.notifier)
                                            .state =
                                        DateTime.now()
                                            .add(const Duration(days: 30 * 6));

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('In 12 months'),
                                  onPressed: () {
                                    ref
                                            .read(expiringDateProvider.notifier)
                                            .state =
                                        DateTime.now()
                                            .add(const Duration(days: 365));

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Custom'),
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final lastDate = DateTime(
                                        now.year + 20, now.month, now.day);

                                    final DateTime? picked =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: now,
                                            firstDate: DateTime(now.year,
                                                now.month - 6, now.day),
                                            lastDate: lastDate);
                                    if (picked != null) {
                                      ref
                                          .read(expiringDateProvider.notifier)
                                          .state = picked;
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            )),
                      );
                    },
                  );
                },
                child: TextFormField(
                  enabled: false, // Make it non-editable
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, top: 12),
                      child: FaIcon(FontAwesomeIcons.calendar,
                          color: Colors.white),
                    ),
                    labelText: "Expires $formattedDateText",
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const Expanded(child: AsyncExpiringStockItemVariationListView())
          ],
        ));
  }
}

String formatExpiryDate(DateTime expiryDate) {
  // Calculate the difference in days from today to the expiry date
  DateTime now = DateTime.now();
  Duration difference = expiryDate.difference(now);
  int daysDifference = difference.inDays;

  if (daysDifference == 30 - 1) {
    return 'in 1 month';
  } else if (daysDifference == 30 * 6 - 1) {
    return 'in 6 months';
  } else if (daysDifference == 364) {
    return 'in 12 months';
  } else {
    return 'within ${formatDate(expiryDate)}';
  }
}
