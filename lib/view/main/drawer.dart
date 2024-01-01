import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // return Drawer(child: ,)

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Dashboard'),
            // selected: _selectedIndex == 0,
            onTap: () {
              log("are we going?");
              context.goNamed(
                AppRoute.dashboard.name,
              );

              // context.go("/items");

              // Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Items'),
            leading: const FaIcon(FontAwesomeIcons.cubesStacked),
            // selected: _selectedIndex == 1,
            onTap: () {
              log("are we going?");
              context.goNamed(
                AppRoute.items.name,
              );

              // context.go("/items");

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
              context.goNamed(
                AppRoute.stockAdjust.name,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.arrowsRotate),
            title: const Text('Transactions'),
            // selected: _selectedIndex == 1,
            onTap: () {
              context.goNamed(AppRoute.stockTransactions.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
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
            title: const Text('Purchase Orders'),
            onTap: () {
              context.goNamed(
                AppRoute.purchaseOrders.name,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
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
