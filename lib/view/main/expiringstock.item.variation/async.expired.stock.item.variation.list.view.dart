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
  final PagingController<int, MapEntry<Option<String>, List<ItemVariation>>>
      _pagingController = PagingController(firstPageKey: 0);
  final _lastIdProvider = StateProvider<Option<String>>(
    (ref) => const None(),
  );

  final Set<String> _expiryGroupingKey = {};

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
        _expiryGroupingKey.clear(); // we need to clear the key
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
      child: PagedListView<int, MapEntry<Option<String>, List<ItemVariation>>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<
                MapEntry<Option<String>, List<ItemVariation>>>(
            noItemsFoundIndicatorBuilder: (context) => Center(
                child: Text(
                    "No items expiring ${formatExpiryDate(ref.watch(expiringDateProvider))}")),
            itemBuilder: (context, itemVariationMap, index) {
              if (itemVariationMap.value.isEmpty) {
                return const SizedBox.shrink();
              }

              if (itemVariationMap.key.isSome()) {
                final key = itemVariationMap.key.toIterable().first;
                final text =
                    key.substring(0, 1).toUpperCase() + key.substring(1);

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _combine(
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            color: Theme.of(context).dividerColor,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, bottom: 12, top: 12),
                              child: Text(text,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                          ),
                        ),
                        itemVariationMap.value
                            .map((t) => _getListTitle(t, context))
                            .toList()));
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: itemVariationMap.value
                      .map((t) => _getListTitle(t, context))
                      .toList());
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
    _expiryGroupingKey.clear();
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

    final f = groupItemsByExpiry(DateTime.now(), itemList);
    // we want to change to Option<String> so the we dont need to display another group with same title (such as Expired in weeks)
    Map<Option<String>, List<ItemVariation>> mapWithOptionString = {};
    for (var v in f.entries) {
      if (_expiryGroupingKey.contains(v.key)) {
        mapWithOptionString[const None()] = v.value;
      } else {
        mapWithOptionString[Some(v.key)] = v.value;
      }
      _expiryGroupingKey.add(v.key);
    }

    if (itemListResponse.hasMore) {
      final nextPageKey = pageKey + itemList.length;
      _pagingController.appendPage(
          mapWithOptionString.entries.toList(), nextPageKey);
    } else {
      _pagingController.appendLastPage(mapWithOptionString.entries.toList());
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

  List<Widget> _combine(Widget w1, List<Widget> w2) {
    //due to text + TransactionItem list, we need to change to widget and combine them
    return [w1] + w2;
  }

  Map<String, List<ItemVariation>> groupItemsByExpiry(
      DateTime currentDate, List<ItemVariation> items) {
    //Generated by ChatGPT
    Map<String, List<ItemVariation>> groupedItems = {
      'expired': [],
      'expired in days': [],
      'expired in weeks': [],
      'expired in months': [],
    };

    for (var item in items) {
      String remainingTime = calculateRemainingTime(
          currentDate, item.expiryDate.fold(() => DateTime.now(), (x) => x));
      if (remainingTime == 'expired') {
        groupedItems['expired']!.add(item);
      } else if (remainingTime.contains('day')) {
        groupedItems['expired in days']!.add(item);
      } else if (remainingTime.contains('week')) {
        groupedItems['expired in weeks']!.add(item);
      } else if (remainingTime.contains('month')) {
        groupedItems['expired in months']!.add(item);
      }
    }

    return groupedItems;
  }

  String calculateRemainingTime(DateTime currentDate, DateTime expiryDate) {
    //Generated by ChatGPT
    if (currentDate.isAfter(expiryDate)) {
      return 'expired';
    }

    Duration difference = expiryDate.difference(currentDate);
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'in 1 day';
      } else if (difference.inDays < 7) {
        return 'in ${difference.inDays} days';
      } else if (difference.inDays < 30) {
        int weeks = (difference.inDays / 7).floor();
        return 'in $weeks weeks';
      } else {
        int months = (difference.inDays / 30).floor();
        return 'in $months months';
      }
    } else {
      int months = difference.inDays ~/ 30;
      return 'in ${months.abs()} months';
    }
  }
}
