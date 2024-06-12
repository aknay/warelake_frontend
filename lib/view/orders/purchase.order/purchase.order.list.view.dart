import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/view/common.widgets/amount.text.dart';
import 'package:warelake/view/common.widgets/date.text.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.list.controller.dart';
import 'package:warelake/view/orders/purchase.order/purchase.order.screen.dart';
import 'package:warelake/view/orders/purchase.order/widgets/purchase.order.status.widget.dart';
import 'package:warelake/view/utils/async_value_ui.dart';
import 'package:warelake/view/utils/date.time.utils.dart';

class PurchaseOrderListView extends ConsumerStatefulWidget {
  const PurchaseOrderListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PurchaseOrderListViewState();
}

class _PurchaseOrderListViewState extends ConsumerState<PurchaseOrderListView> {
  final PagingController<int, MapEntry<DateTime, List<PurchaseOrder>>> _pagingController =
      PagingController(firstPageKey: 0);

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
      child: PagedListView<int, MapEntry<DateTime, List<PurchaseOrder>>>(
        pagingController: _pagingController,
        builderDelegate:
            PagedChildBuilderDelegate<MapEntry<DateTime, List<PurchaseOrder>>>(itemBuilder: (context, item, index) {
          return _getListTitlesWithDateTime(item, context);
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

    final f = groupBy(poList, (p0) => p0.date.removeTime());

    if (poListListResponse.hasMore) {
      final nextPageKey = pageKey + poList.length;
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

  Widget _getListTitlesWithDateTime(MapEntry<DateTime, List<PurchaseOrder>> stx, BuildContext context) {
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

  ListTile _getListTitle(PurchaseOrder po, BuildContext context) {
    final subtitle = "${po.lineItems.length} Items | ${po.lineItems.map((e) => e.quantity).sum} Quantity";

    return ListTile(
      title: Text(po.purchaseOrderNumber!),
      subtitle: Text(subtitle),
      onTap: () {
        if (po.id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => PurchaseOrderScreen(purchaseOrderId: po.id!),
            ),
          );
        }
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
