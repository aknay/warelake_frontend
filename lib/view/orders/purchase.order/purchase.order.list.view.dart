import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/common.widgets/amount.text.dart';
import 'package:warelake/view/common.widgets/date.text.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.list.controller.dart';
import 'package:warelake/view/orders/purchase.order/widgets/purchase.order.status.widget.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/utils/async_value_ui.dart';

class PurchaseOrderListView extends ConsumerStatefulWidget {
  const PurchaseOrderListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PurchaseOrderListViewState();
}

class _PurchaseOrderListViewState extends ConsumerState<PurchaseOrderListView> {
  final PagingController<int, PurchaseOrder> _pagingController = PagingController(firstPageKey: 0);

  final _lastStockTransactionIdProvider = StateProvider<Option<String>>(
    (ref) => const None(),
  );
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(purchaseOrderListControllerProvider, (_, state) => state.showAlertDialogOnError(context));

    //we will refresh the view if there is change in sale order list
    ref.listen<AsyncValue>(purchaseOrderListControllerProvider, (_, state) => _refresh());

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, PurchaseOrder>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<PurchaseOrder>(itemBuilder: (context, item, index) {
          return _getListTitle(item, context);
        }),
      ),
    );
  }

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

  Future<void> _fetchPage(int pageKey) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final lastPoId = ref.read(_lastStockTransactionIdProvider).toNullable();
    final poListResponseOrError =
        await ref.read(purchaseOrderListControllerProvider.notifier).list(lastPurchaseOrderId: lastPoId);

    if (poListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final poListListResponse = poListResponseOrError.toIterable().first;
    final poList = poListListResponse.data;

    if (poList.isNotEmpty) {
      ref.read(_lastStockTransactionIdProvider.notifier).state = Some(poList.last.id!);
    } else {
      log("po list is empty");
    }

    if (poListListResponse.hasMore) {
      final nextPageKey = pageKey + poList.length;
      _pagingController.appendPage(poList, nextPageKey);
    } else {
      _pagingController.appendLastPage(poList);
    }
  }

  ListTile _getListTitle(PurchaseOrder po, BuildContext context) {
    return ListTile(
      title: Text(po.purchaseOrderNumber!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateText(po.date),
        ],
      ),
      onTap: () {
        context.goNamed(
          AppRoute.purchaseOrder.name,
          pathParameters: {'id': po.id!},
        );
      },
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AmountText(
              po.totalInDouble,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            PurchaseOrderStausWidget(po.status),
          ],
        ),
      ),
    );
  }
}
