import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/item.variations/async.item.variation.list.by.item.id.controller.dart';
import 'package:warelake/view/item.variations/item.variation.list.controller.dart';
import 'package:warelake/view/items/item.image/item.image.widget.dart';
import 'package:warelake/view/items/item.list.controller.dart';
import 'package:warelake/view/routing/app.router.dart';

import '../item.variations/item.variation.list.view.dart';

class EditItemGroupScreen extends ConsumerStatefulWidget {
  const EditItemGroupScreen({super.key, required this.item});

  final Item item;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditItemGroupScreenState();
}

class _EditItemGroupScreenState extends ConsumerState<EditItemGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemName = const None();
  Option<String> itemUnit = const None();

  @override
  void initState() {
    super.initState();
    itemName = Some(widget.item.name);
    itemUnit = Some(widget.item.unit);
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
      context.pop(
        ItemUpdatePayload(
          name: itemName.toNullable(),
          unit: itemUnit.toNullable(),
          newItemVariationListOrNone: ref.watch(itemVariationListControllerProvider),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);

    final asyncItemVariations = ref.watch(asyncItemVariationListByItemIdControllerProvider(itemId: widget.item.id!));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item Group"),
        actions: [
          IconButton(onPressed: state.isLoading ? null : _submit, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            gapH8,
            ItemImageWidget(itemId: widget.item.id!, isForTheList: false),
            gapH32,
            TextFormField(
              initialValue: itemName.getOrElse(() => ""),
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'Enter Item Name',
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
              initialValue: itemUnit.getOrElse(() => ""),
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
            gapH16,
            Text('New Items', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
                child: ItemVariationListView(
              itemVariationList: ref.watch(itemVariationListControllerProvider),
              isToSelectItemVariation: false,
            )),
            OutlinedButton(
              onPressed: () async {
                final ItemVariation? itemVariation = await context.pushNamed(AppRoute.addItemVariation.name);
                if (itemVariation != null) {
                  ref.read(itemVariationListControllerProvider.notifier).upset(itemVariation);
                }
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Add more items'),
            ),
            gapH16,
            Text('Existing Items', style: Theme.of(context).textTheme.titleLarge),
            asyncItemVariations.when(
                data: (data) {
                  return Expanded(
                    child: ItemVariationListView(
                      itemVariationList: data,
                      isToSelectItemVariation: false,
                    ),
                  );
                },
                error: (object, error) => Text("$error"),
                loading: () => const Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }
}
