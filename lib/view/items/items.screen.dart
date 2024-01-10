import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';
import 'package:inventory_frontend/view/items/item.list.view.dart';
import 'package:inventory_frontend/view/main/drawer.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Items")),
      body: Column(
        children: [
          TextField(
            onChanged: (value) async {
              await ref.read(itemListControllerProvider.notifier).search(value);
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: "Search item name",
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              border: const OutlineInputBorder(),
            ),
          ),
          const Expanded(child: ItemListView(isToSelectItemVariation: false)),
        ],
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(AppRoute.addItem.name);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
