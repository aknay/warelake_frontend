import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.service.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/stock/transactions/entities.dart';
import 'package:warelake/view/stock/transactions/stock.filter.provider.dart';

class StockTransactionListView extends ConsumerStatefulWidget {
  const StockTransactionListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockTransactionListViewState();
}

class _StockTransactionListViewState extends ConsumerState<StockTransactionListView> {
  final PagingController<int, StockTransaction> _pagingController = PagingController(firstPageKey: 0);

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
      stockTransctionFilterProvider,
      (_, state) {
        log("refresh from other pages?");
        _refresh();
      },
    );
    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, StockTransaction>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<StockTransaction>(itemBuilder: (context, item, index) {
          return _getListTitle(item, context);
        }),
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final lastStockTranasactionId = ref.read(_lastStockTransactionIdProvider).toNullable();
    final stockTransactionFilter = ref.read(stockTransctionFilterProvider);
    final stockTransactionListResponseOrError = await ref
        .read(stockTransactionServiceProvider)
        .list(lastStockTransactionId: lastStockTranasactionId, stockMovement: stockTransactionFilter.stockMovement);

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

    if (stockTransactionListResponse.hasMore) {
      final nextPageKey = pageKey + stockTransactionList.length;
      _pagingController.appendPage(stockTransactionList, nextPageKey);
    } else {
      _pagingController.appendLastPage(stockTransactionList);
    }
  }

  ListTile _getListTitle(StockTransaction stx, BuildContext context) {
    FaIcon icon;
    String stockMovementText;
    switch (stx.stockMovement) {
      case StockMovement.stockIn:
        icon = const FaIcon(FontAwesomeIcons.arrowRightToBracket);
        stockMovementText = "Stock In";
      case StockMovement.stockOut:
        icon = const FaIcon(FontAwesomeIcons.arrowRightFromBracket);
        stockMovementText = "Stock Out";
      case StockMovement.stockAdjust:
        icon = const FaIcon(FontAwesomeIcons.rightLeft);
        stockMovementText = "Stock Adjust";
    }

    return ListTile(
      leading: icon,
      title: Text(stockMovementText),
      trailing: Text(stx.date),
      onTap: () {
        context.goNamed(
          AppRoute.stockTransactionDetail.name,
          pathParameters: {'id': stx.id!},
        );
      },
    );
  }
}
