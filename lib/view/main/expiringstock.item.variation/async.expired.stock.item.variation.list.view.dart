import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:warelake/data/item.variation/item.variation.service.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/view/item.variations/item.variation.image/item.variation.image.widget.dart';
import 'package:warelake/view/item.variations/item.variation.screen.dart';
import 'package:warelake/view/main/expiringstock.item.variation/expiring.stock.item.variations.screen.dart';
import 'package:warelake/view/widgets/expired.label.dart';

// we will use this to refresh item list from another screen after certain action (such as edit or remove) is done.
// we use bool type so that we can toggle. the value should be diffrent from current state
final toForceToRefreshIemListProvider = StateProvider<bool>(
  (ref) => true,
);

class AsyncExpiringStockItemVariationListView extends ConsumerStatefulWidget {
  const AsyncExpiringStockItemVariationListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ItemVariationListViewState();
}

class _ItemVariationListViewState
    extends ConsumerState<AsyncExpiringStockItemVariationListView> {
  final PagingController<int, ItemVariation> _pagingController =
      PagingController(firstPageKey: 0);
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
    ref.listen<DateTime>(
      expiringDateProvider,
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
        builderDelegate: PagedChildBuilderDelegate<ItemVariation>(
            noItemsFoundIndicatorBuilder: (context) => Center(
                child: Text(
                    "No items expiring ${formatExpiryDate(ref.watch(expiringDateProvider))}")),
            itemBuilder: (context, item, index) {
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
    final dateTime = ref.read(expiringDateProvider);
    final itemListResponseOrError = await ref
        .read(itemVariationServiceProvider)
        .getExpiringStockItemVarations(dateTime,
            startingAfterId: ref.read(_lastIdProvider));

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

  ListTile _getListTitle(ItemVariation itemVariation, BuildContext context) {
    return ListTile(
      leading: ItemVariationImageWidget(
          itemId: itemVariation.itemId,
          itemVariationId: itemVariation.id!,
          isForTheList: true),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(itemVariation.name),
          ),
          itemVariation.expiryDate.fold(() => const SizedBox.shrink(), (x) {
            if (x.isBefore(DateTime.now())) {
              return const ExpiredItemLabel("Expired");
            }
            return Text(timeago.format(x, allowFromNow: true));
          })
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ItemVariationScreen(
                  itemId: itemVariation.itemId!,
                  itemVariationId: itemVariation.id!)),
        );
      },
    );
  }
}
