import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/main/drawer/user.info.widget.dart';
import 'package:warelake/view/routing/app.router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: 8),
              child: UserInfoWidget(),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.house),
            title: const Text('Dashboard'),
            onTap: () {
              log("are we going?");
              context.goNamed(
                AppRoute.dashboard.name,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Items'),
            leading: const FaIcon(FontAwesomeIcons.cubesStacked),
            onTap: () {
              log("are we going?");
              context.goNamed(
                AppRoute.items.name,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Stock In'),
            leading: const FaIcon(FontAwesomeIcons.arrowRightToBracket),
            onTap: () {
              context.goNamed(AppRoute.stockIn.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Stock Out'),
            leading: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            onTap: () {
              context.goNamed(AppRoute.stockOut.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.rightLeft),
            title: const Text('Stock Adjust'),
            onTap: () {
              context.goNamed(AppRoute.stockAdjust.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.arrowsRotate),
            title: const Text('Transactions'),
            onTap: () {
              context.goNamed(AppRoute.stockTransactions.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.fileInvoiceDollar),
            title: const Text('Sale Orders'),
            onTap: () {
              log("are we going?");
              context.goNamed(
                AppRoute.saleOrders.name,
              );

              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.bagShopping),
            title: const Text('Purchase Orders'),
            onTap: () {
              context.goNamed(
                AppRoute.purchaseOrders.name,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.moneyBillTransfer),
            title: const Text('Account'),
            onTap: () {
              context.goNamed(
                AppRoute.billAccounts.name,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    // return const Placeholder();
  }
}
