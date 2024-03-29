import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/items/item.list.controller.dart';
import 'package:warelake/view/item.variations/item.variation.list.controller.dart';
import 'package:warelake/view/item.variations/item.variation.list.view.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/utils/alert_dialogs.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key, required this.item});
  final Option<Item> item;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemName = const None();
  Option<String> itemUnit = const None();

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
      final itemVariations = ref.read(itemVariationListControllerProvider);

      if (itemVariations.isEmpty) {
        showAlertDialog(
          context: context,
          title: "Item",
          defaultActionText: "OK",
          content: "Please add at least one item.",
        );

        return;
      }

      final item =
          Item.create(name: itemName.toIterable().first, variations: itemVariations, unit: itemUnit.toIterable().first);

      final isCreated = await ref.read(itemListControllerProvider.notifier).createItem(item);

      if (isCreated && mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);
    final itemVariationList = ref.watch(itemVariationListControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ItemVariation? itemVariation = await context.pushNamed(AppRoute.addItemVariation.name);
          if (itemVariation != null) {
            ref.read(itemVariationListControllerProvider.notifier).upset(itemVariation);
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Add Item Group"),
        actions: [
          IconButton(onPressed: state.isLoading ? null : _submit, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              gapH8,
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Item Group Name *',
                  hintText: 'Enter Item Group Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a item name';
                  }
                  return null;
                },
                onSaved: (value) => itemName = optionOf(value),
              ),
              gapH8,
              TextFormField(
                // initialValue: widget.itemVariation == null ? null : widget.itemVariation!.type,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  hintText: 'Enter unit',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
                onSaved: (value) => itemUnit = optionOf(value),
              ),
              Expanded(
                child:
                    ItemVariationListView(itemVariationList: itemVariationList.toList(), isToSelectItemVariation: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
