import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/common.widgets/amount.text.dart';
import 'package:warelake/view/common.widgets/date.text.dart';
import 'package:warelake/view/orders/sale.orders/sale.order.list.controller.dart';
import 'package:warelake/view/orders/sale.orders/widgets/sale.order.status.widget.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/utils/async_value_ui.dart';

class SaleOrderListView extends ConsumerStatefulWidget {
  const SaleOrderListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SaleOrderListViewState();
}

class _SaleOrderListViewState extends ConsumerState<SaleOrderListView> {
  final PagingController<int, SaleOrder> _pagingController = PagingController(firstPageKey: 0);

  final _lastSaleOrerIdProvider = StateProvider<Option<String>>(
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
    ref.listen<AsyncValue>(
      saleOrderListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    //we will refresh the view if there is change in sale order list
    ref.listen<AsyncValue>(saleOrderListControllerProvider, (_, state) => _refresh());

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, SaleOrder>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<SaleOrder>(itemBuilder: (context, item, index) {
          return _getListTitle(item, context);
        }),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.read(_lastSaleOrerIdProvider.notifier).state = const None();
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final lastSoId = ref.read(_lastSaleOrerIdProvider).toNullable();
    final soListResponseOrError =
        await ref.read(saleOrderListControllerProvider.notifier).list(lastSaleOrderId: lastSoId);

    if (soListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final soListListResponse = soListResponseOrError.toIterable().first;
    final soList = soListListResponse.data;

    if (soList.isNotEmpty) {
      ref.read(_lastSaleOrerIdProvider.notifier).state = Some(soList.last.id!);
    } else {
      log("po list is empty");
    }

    if (soListListResponse.hasMore) {
      final nextPageKey = pageKey + soList.length;
      _pagingController.appendPage(soList, nextPageKey);
    } else {
      _pagingController.appendLastPage(soList);
    }
  }

  ListTile _getListTitle(SaleOrder so, BuildContext context) {
    return ListTile(
      title: Text(so.saleOrderNumber!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateText(so.date),
        ],
      ),
      onTap: () {
        context.goNamed(
          AppRoute.saleOrder.name,
          pathParameters: {'id': so.id!},
        );
      },
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AmountText(
              so.totalInDouble,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SaleOrderStausWidget(so.status),
          ],
        ),
      ),
    );
  }
}
