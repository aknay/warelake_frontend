import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/sale.order/sale.order.service.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/sale.order/entities.dart';

part 'sale.order.list.controller.g.dart';

@riverpod
class SaleOrderListController extends _$SaleOrderListController {
  @override
  Future<List<SaleOrder>> build() async {
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first.data;
  }

  Future<bool> createSaleOrder(SaleOrder saleOrder) async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(saleOrderServiceProvider).createSaleOrder(saleOrder);
    return await createdOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final saleOrdersOrError = await _list();
      if (saleOrdersOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(saleOrdersOrError.toIterable().first.data);
      return true;
    });
  }

  Future<bool> convertToDelivered(SaleOrder saleOrder) async {
    state = const AsyncLoading();
    final delieveredOrError = await ref.read(saleOrderServiceProvider).converteToDelivered(saleOrderId: saleOrder.id!);
    return await delieveredOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final saleOrdersOrError = await _list();
      if (saleOrdersOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(saleOrdersOrError.toIterable().first.data);
      return true;
    });
  }

  Future<bool> delete(SaleOrder saleOrder) async {
    state = const AsyncLoading();
    final delieveredOrError = await ref.read(saleOrderServiceProvider).delete(saleOrder: saleOrder);
    return await delieveredOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final saleOrdersOrError = await _list();
      if (saleOrdersOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(saleOrdersOrError.toIterable().first.data);
      return true;
    });
  }

    Future<Either<String, ListResponse<SaleOrder>>> list({String? lastSaleOrderId}) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(saleOrderServiceProvider).list(lastSaleOrderId: lastSaleOrderId);
  }

  Future<Either<String, ListResponse<SaleOrder>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(saleOrderServiceProvider).list();
  }
}
