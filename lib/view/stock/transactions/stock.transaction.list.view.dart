import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inventory_frontend/data/stock.transaction/stock.transaction.service.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

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

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, StockTransaction>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<StockTransaction>(itemBuilder: (context, item, index) {
        return _getListTitle(item, context);
      }),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    final stockTransactionListResponseOrError = await ref
        .read(stockTransactionServiceProvider)
        .list(lastStockTransactionIdOrNone: ref.read(_lastStockTransactionIdProvider));

    if (stockTransactionListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final stockTransactionListResponse = stockTransactionListResponseOrError.toIterable().first;
    final stockTransactionList = stockTransactionListResponse.data;

    if (stockTransactionList.isNotEmpty) {
      ref.read(_lastStockTransactionIdProvider.notifier).state = Some(stockTransactionList.last.id!);
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
