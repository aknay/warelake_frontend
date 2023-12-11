import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/items/item.list.controller.dart';
import 'package:inventory_frontend/view/items/item.variation.list.view.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

final itemVariationListProvider = StateProvider<List<ItemVariation>>(
  // only list works, not map
  (ref) => [],
);

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key, required this.item});
  final Option<Item> item;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemName = const None();

  @override
  void initState() {
    super.initState();
    widget.item.fold(() => null, (a) {
      itemName = Some(a.name);
    });
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _submit() async {
    if (_validateAndSaveForm()) {
      final itemVariations = ref.read(itemVariationListProvider);

      final item = Item.create(name: itemName.toIterable().first, variations: itemVariations, unit: "unit");

      final isCreated = await ref.read(itemListControllerProvider.notifier).createItem(item);

      if (isCreated && mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);
    final itemVariationList = ref.watch(itemVariationListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ItemVariation? itemVariation = await context.pushNamed(AppRoute.addItemVariation.name);
          if (itemVariation != null) {
            ref.read(itemVariationListProvider.notifier).update((state) {
              return [...state, itemVariation];
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Add Items"),
        actions: [
          IconButton(onPressed: state.isLoading ? null : _submit, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'Enter Item Name',
                suffixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Item Name';
                }
                return null;
              },
              onSaved: (value) => itemName = optionOf(value),
            ),
            Expanded(
              child: ItemVariationListView(itemVariationList: itemVariationList.toList()),
            )
          ],
        ),
      ),
    );
  }
}
