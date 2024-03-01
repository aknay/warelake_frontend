import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/view/item.variations/item.variations.screen/item.variation.list.view/item.variation.search.widget.dart';
import 'package:warelake/view/items/item.search.widget.dart';

// we will use this to refresh item list from another screen after certain action (such as edit or remove) is done.
// we use bool type so that we can toggle. the value should be diffrent from current state
final toForceToRefreshIemListProvider = StateProvider<bool>(
  (ref) => true,
);

class ItemVariationListView extends ConsumerStatefulWidget {
  final bool isToSelectItemVariation;
  const ItemVariationListView({super.key, required this.isToSelectItemVariation});

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
          return _getListTitle(item, context);
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

  ListTile _getListTitle(ItemVariation item, BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: Text(item.name),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
      },
    );
  }
}
