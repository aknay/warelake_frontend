import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/item.variations/item.variation.image/item.variation.image.widget.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variation.list.view/item.variation.search.widget.dart';
import 'package:warelake/view/orders/common.widgets/line.item/selected.line.item.controller.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/stock.line.item.list.view/stock.line.item.controller.dart';

// we will use this to refresh item list from another screen after certain action (such as edit or remove) is done.
// we use bool type so that we can toggle. the value should be diffrent from current state
final toForceToRefreshIemListProvider = StateProvider<bool>(
  (ref) => true,
);

enum ItemVariationSelection {
  forStockTransaction,
  forOrder,
}

class ItemVariationListView extends ConsumerStatefulWidget {
  final bool isToSelectItemVariation;
  final Option<ItemVariationSelection> itemVariationSelectionOrNone;

  const ItemVariationListView(
      {super.key, required this.isToSelectItemVariation, required this.itemVariationSelectionOrNone});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemVariationListViewState();
}

class _ItemVariationListViewState extends ConsumerState<ItemVariationListView> {
  final PagingController<int, ItemVariation> _pagingController = PagingController(firstPageKey: 0);
  final _lastIdProvider = StateProvider<Option<String>>(
    (ref) => const None(),
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Option<String>>(
      searchItemVariationByBarcodeProvider,
      (_, state) {
        ref.read(_lastIdProvider.notifier).state = const None();
        _pagingController.refresh();
      },
    );

    ref.listen<bool>(
      toForceToRefreshIemListProvider,
      (_, state) {
        log("refresh from other pages?");
        _refresh();
      },
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, ItemVariation>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<ItemVariation>(itemBuilder: (context, item, index) {
          return _getListTitle(item, widget.isToSelectItemVariation, context);
        }),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.read(_lastIdProvider.notifier).state = const None();
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    final searchField = ItemVariationSearchField(
        barcode: ref.read(searchItemVariationByBarcodeProvider).toNullable(),
        startingAfterId: ref.read(_lastIdProvider).toNullable());
    final itemListResponseOrError = await ref.read(itemServiceProvider).listItemVaration(itemSearchField: searchField);

    if (itemListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final itemListResponse = itemListResponseOrError.toIterable().first;
    final itemList = itemListResponse.data;

    if (itemList.isNotEmpty) {
      ref.read(_lastIdProvider.notifier).state = Some(itemList.last.id!);
    } else {
      log("item list is empty");
    }

    if (itemListResponse.hasMore) {
      final nextPageKey = pageKey + itemList.length;
      _pagingController.appendPage(itemList, nextPageKey);
    } else {
      _pagingController.appendLastPage(itemList);
    }
  }

  ListTile _getListTitle(ItemVariation itemVariation, bool isToSelectItemVariation, BuildContext context) {
    final trailingOrNull = isToSelectItemVariation ? null : const Icon(Icons.arrow_forward_ios);
    return ListTile(
      leading: ItemVariationImageWidget(
          itemId: itemVariation.itemId, itemVariationId: itemVariation.id!, isForTheList: true),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: Text(itemVariation.name),
      ),
      trailing: trailingOrNull,
      onTap: () {
        if (isToSelectItemVariation) {
          widget.itemVariationSelectionOrNone.fold(() => null, (selection) {
            switch (selection) {
              case ItemVariationSelection.forStockTransaction:
                ref
                    .read(stockLineItemControllerProvider.notifier)
                    .add(StockLineItem.create(itemVariation: itemVariation, quantity: 1));
                GoRouter.of(context).pop();
              case ItemVariationSelection.forOrder:
                ref.read(selectedItemVariationProvider.notifier).state = Some(itemVariation);
                    GoRouter.of(context).pop();
              // TODO: Handle this case.
            }
          });
        } else {
          context.goNamed(AppRoute.itemVariationDetail.name,
              pathParameters: {'id': itemVariation.id!}, queryParameters: {'itemId': itemVariation.itemId});
        }
      },
    );
  }
}
