import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/stock/new.stock.transaction.screen.dart';

class StockInOutWidget extends ConsumerWidget {
  const StockInOutWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('New Stock In / Out', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.rightToBracket),
              title: const Text('Stock In'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewStockTransactionScreen(
                            stockMovement: StockMovement.stockIn,
                          ),
                      fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.rightFromBracket),
              title: const Text('Stock Out'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewStockTransactionScreen(stockMovement: StockMovement.stockOut),
                      fullscreenDialog: true),
                );
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.rightLeft),
              title: const Text('Stock Adjust'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewStockTransactionScreen(stockMovement: StockMovement.stockAdjust),
                      fullscreenDialog: true),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
