import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/view/common.widgets/stock.count.widget.dart';
import 'package:warelake/view/item.variations/add.item.variance.screen.dart';
import 'package:warelake/view/item.variations/async.item.variation.list.by.item.id.controller.dart';
import 'package:warelake/view/item.variations/item.variation.image/item.variation.image.widget.dart';
import 'package:warelake/view/item.variations/item.variation.list.controller.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';

class AsyncItemVariationByItemIdListView extends ConsumerWidget {
  const AsyncItemVariationByItemIdListView({required this.isToSelectItemVariation, required this.itemId, super.key});

  final bool isToSelectItemVariation;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItemVariations = ref.watch(asyncItemVariationListByItemIdControllerProvider(itemId: itemId));

    return asyncItemVariations.when(
        data: (itemVariationList) {
          if (itemVariationList.isEmpty) {
            return const Center(child: Text("No item available"));
          }
          return ListView(
            children: itemVariationList
                .map((e) => ListTile(
                      leading: ItemVariationImageWidget(
                        itemId: e.itemId,
                        itemVariationId: e.id!,
                        isForTheList: true,
                        imageUrlOrNone: optionOf(e.imageUrl),
                      ),
                      title: Text(e.name),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [const Text("Stock on hand: "), StockCount(amount: e.itemCount!)],
                      ),
                      trailing: e.itemId == null
                          ? IconButton(
                              onPressed: () {
                                ref.read(itemVariationListControllerProvider.notifier).delete(e);
                              },
                              icon: const FaIcon(FontAwesomeIcons.xmark))
                          : const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        if (isToSelectItemVariation) {
                          ref.read(selectedItemVariationProvider.notifier).state = Some(e);
                        } else {
                          if (e.itemId == null) {
                            //we want to edit local item variation
                            final ItemVariation? itemVariation = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddItemVariationScreen(itemVariation: Some(e)),
                              ),
                            );
                            if (itemVariation != null) {
                              ref.read(itemVariationListControllerProvider.notifier).upset(itemVariation);
                            }
                          } else {
                            context.goNamed(
                              AppRoute.variationItem.name,
                              pathParameters: {'id': e.itemId!, 'variation_item_id': e.id!},
                            );
                          }
                        }
                      },
                    ))
                .toList(),
          );
        },
        error: (object, error) => Text("$error"),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
