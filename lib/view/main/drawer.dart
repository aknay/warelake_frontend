import 'dart:developer';

import 'package:flutter/material.dart';
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
            title: const Text('School'),
            // selected: _selectedIndex == 2,
            onTap: () {
              // Update the state of the app
              // _onItemTapped(2);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    // return const Placeholder();
  }
}
