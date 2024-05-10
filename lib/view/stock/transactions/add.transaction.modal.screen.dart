import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/constants/colors.dart';
import 'package:warelake/view/stock/new.stock.transaction.screen.dart';

class AddTransactionModalScreen extends ConsumerWidget {
  const AddTransactionModalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.arrowRightToBracket, color: rallyGreen),
            title: const Text('Stock In'),
            onTap: () {
              context.pop();
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
            leading: const FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: Colors.redAccent,
            ),
            title: const Text('Stock Out'),
            onTap: () {
              context.pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewStockTransactionScreen(
                          stockMovement: StockMovement.stockOut,
                        ),
                    fullscreenDialog: true),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.rightLeft,
              color: rallyYellow,
            ),
            title: const Text('Stock Adjust'),
            onTap: () {
              context.pop();

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewStockTransactionScreen(
                          stockMovement: StockMovement.stockAdjust,
                        ),
                    fullscreenDialog: true),
              );
            },
          ),
        ],
      ),
    );
  }
}
