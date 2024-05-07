import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.service.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/common.widgets/date.text.dart';
import 'package:warelake/view/constants/colors.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/stock.transaction.list.controller.dart';
import 'package:warelake/view/stock/transactions/entities.dart';
import 'package:warelake/view/stock/transactions/stock.filter.provider.dart';
import 'package:warelake/view/utils/date.time.utils.dart';

class StockTransactionListView extends ConsumerStatefulWidget {
  const StockTransactionListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockTransactionListViewState();
}

class _StockTransactionListViewState extends ConsumerState<StockTransactionListView> {
  final PagingController<int, MapEntry<DateTime, List<StockTransaction>>> _pagingController =
      PagingController(firstPageKey: 0);

  final _lastStockTransactionIdProvider = StateProvider<Option<String>>(
    (ref) => const None(),
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _refresh() async {
    ref.read(_lastStockTransactionIdProvider.notifier).state = const None();
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StockTransactionFilter?>(
      stockTransactionFilterProvider,
      (_, state) {
        log("refresh from other pages?");
        _refresh();
      },
    );

    //we will refresh the view if there is change in sale order list
    ref.listen<AsyncValue>(stockTransactionListControllerProvider, (_, state) => _refresh());

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, MapEntry<DateTime, List<StockTransaction>>>(
        pagingController: _pagingController,
        builderDelegate:
            PagedChildBuilderDelegate<MapEntry<DateTime, List<StockTransaction>>>(itemBuilder: (context, item, index) {
          return _getListTitlesWithDateTime(item, context);
        }),
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final lastStockTransactionId = ref.read(_lastStockTransactionIdProvider).toNullable();
    final stockTransactionFilter = ref.read(stockTransactionFilterProvider);
    final stockTransactionListResponseOrError = await ref
        .read(stockTransactionServiceProvider)
        .list(lastStockTransactionId: lastStockTransactionId, stockMovement: stockTransactionFilter.stockMovement);

    if (stockTransactionListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final stockTransactionListResponse = stockTransactionListResponseOrError.toIterable().first;
    final stockTransactionList = stockTransactionListResponse.data;

    if (stockTransactionList.isNotEmpty) {
      ref.read(_lastStockTransactionIdProvider.notifier).state = Some(stockTransactionList.last.id!);
    } else {
      log("item list is empty");
    }

    final f = groupBy(stockTransactionList, (p0) => p0.date.removeTime());

    if (stockTransactionListResponse.hasMore) {
      final nextPageKey = pageKey + stockTransactionList.length;
      _pagingController.appendPage(f.entries.toList(), nextPageKey);
    } else {
      _pagingController.appendLastPage(f.entries.toList());
    }
  }

  List<Widget> _combine(Widget w1, List<Widget> w2) {
    //due to text + TransactionItem list, we need to change to widget and combine them
    const divider = Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 16), child: Divider());
    return [w1] + w2 + [divider];
  }

  Widget _getListTitlesWithDateTime(MapEntry<DateTime, List<StockTransaction>> stx, BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _combine(
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: DateText(
                stx.key,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).hintColor),
              ),
            ),
            stx.value.map((e) => _getListTitle(e, context)).toList()));
  }

  ListTile _getListTitle(StockTransaction stx, BuildContext context) {
    FaIcon icon;
    String stockMovementText;
    const iconSize = 18.0;
    switch (stx.stockMovement) {
      case StockMovement.stockIn:
        icon = const FaIcon(FontAwesomeIcons.arrowRightToBracket, color: rallyGreen, size: iconSize);
        stockMovementText = "Stock In";
        break;
      case StockMovement.stockOut:
        icon = const FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.deepOrangeAccent, size: iconSize);
        stockMovementText = "Stock Out";
        break;
      case StockMovement.stockAdjust:
        icon = const FaIcon(FontAwesomeIcons.rightLeft, color: rallyYellow, size: iconSize);
        stockMovementText = "Stock Adjust";
    }
    final subtitle = "${stx.lineItems.length} Items | ${stx.lineItems.map((e) => e.quantity).sum} Quantity";
    return ListTile(
      leading: icon,
      title: Text(stockMovementText),
      trailing: Text(subtitle),
      onTap: () {
        context.goNamed(
          AppRoute.stockTransactionDetail.name,
          pathParameters: {'id': stx.id!},
        );
      },
    );
  }
}
