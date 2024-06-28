import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:warelake/view/main/expiringstock.item.variation/async.expired.stock.item.variation.list.view.dart';

final dateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now().add(const Duration(days: 22));
});

class ExpiringStockItemVariationsScreen extends ConsumerWidget {
  const ExpiringStockItemVariationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = ref.watch(dateProvider);

    final formattedDateText = formatExpiryDate(dateTime);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Expiration Check"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    // constraints: BoxConstraints(
                    //     maxHeight: MediaQuery.of(context).size.height * 0.15),
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
                                    ref.read(dateProvider.notifier).state =
                                        addMonths(DateTime.now(), 1);

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('In 6 months'),
                                  onPressed: () {
                                    ref.read(dateProvider.notifier).state =
                                        DateTime.now()
                                            .add(const Duration(days: 30 * 6));

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('In 12 months'),
                                  onPressed: () {
                                    ref.read(dateProvider.notifier).state =
                                        DateTime.now()
                                            .add(const Duration(days: 365));

                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Custom'),
                                  onPressed: () => Navigator.pop(context),
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
                    labelText: formattedDateText,
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            ElevatedButton(onPressed: () {}, child: const Text('hjello')),
            const Expanded(child: AsyncExpiringStockItemVariationListView())
          ],
        ));
  }

  String formatExpiryDate(DateTime expiryDate) {
    // Calculate the difference in days from today to the expiry date
    DateTime now = DateTime.now();
    Duration difference = expiryDate.difference(now);
    int daysDifference = difference.inDays;

    Logger().d("diff now ${now}");
    Logger().d("diff expir ${expiryDate}");
    Logger().d("diff ${daysDifference}");

    if (daysDifference < 0) {
      // Expiry date is in the past
      return 'Expired on ${DateFormat.yMMMd().format(expiryDate)}';
    } else if (daysDifference == 0) {
      // Expiry date is today
      return 'Expires today';
    } else if (daysDifference == 1) {
      // Expiry date is tomorrow
      return 'Expires tomorrow';
    } else if (daysDifference <= 7) {
      // Expiry date is within the next week
      return 'Expires in ${daysDifference} days';
    } else if (daysDifference <= 30) {
      // Expiry date is within the next month
      return 'Expires in ${daysDifference ~/ 7} weeks';
    } else if (daysDifference <= 180) {
      // Expiry date is within the next 6 months
      int monthsDifference = (daysDifference / 30).ceil();
      return 'Expires in $monthsDifference months';
    } else if (daysDifference <= 365) {
      // Expiry date is within the next year
      return 'Expires in 12 months';
    } else {
      // Expiry date is more than a year away
      return 'Expires on ${DateFormat.yMMMd().format(expiryDate)}';
    }
  }

  DateTime addMonths(DateTime dateTime, int monthsToAdd) {
    int year = dateTime.year + monthsToAdd ~/ 12;
    int month = dateTime.month + monthsToAdd % 12;
    if (month > 12) {
      year++;
      month -= 12;
    }
    int day = dateTime.day;

    // Handle edge case where adding months may overshoot to the next month
    int daysInNextMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInNextMonth) {
      day = daysInNextMonth;
    }

    return DateTime(year, month, day, dateTime.hour, dateTime.minute,
        dateTime.second, dateTime.millisecond, dateTime.microsecond);
  }
}
