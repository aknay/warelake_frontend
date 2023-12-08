import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';

class ItemListView extends ConsumerWidget {
  const ItemListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      itemListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final asyncItemList = ref.watch(itemListControllerProvider);

    return asyncItemList.when(
        data: (data) {
          return ListView(
              children: data
                  .map((e) => ListTile(
                        title: Text(e.name),
                        onTap: () {
                          context.goNamed(
                            AppRoute.viewItem.name,
                            pathParameters: {'id': e.itemId!},
                          );
                        },
                      ))
                  .toList());
        },
        error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
