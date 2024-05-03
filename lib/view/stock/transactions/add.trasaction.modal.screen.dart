import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/constants/colors.dart';
import 'package:warelake/view/routing/app.router.dart';

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
              context.goNamed(AppRoute.stockInFromTransactionList.name);
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
              context.goNamed(AppRoute.stockOutFromTransactionList.name);
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
              context.goNamed(AppRoute.stockAdjustFromTransactionList.name);
            },
          ),
        ],
      ),
    );
  }
}
