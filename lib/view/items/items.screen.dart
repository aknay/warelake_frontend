import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/items/item.list.view.dart';
import 'package:warelake/view/items/item.search.widget.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/routing/app.router.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Groups")),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ItemSearchWidget(),
          ),
          Expanded(child: ItemListView(isToSelectItemVariation: false)),
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
