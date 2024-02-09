import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/purchase.order/purchase.order.service.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/responses.dart';

part 'purchase.order.list.controller.g.dart';

@riverpod
class PurchaseOrderListController extends _$PurchaseOrderListController {
  @override
  Future<List<PurchaseOrder>> build() async {
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first.data;
  }

  Future<bool> createPurchaseOrder(PurchaseOrder po) async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(purchaseOrderServiceProvider).createPurchaseOrder(po);
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

  Future<bool> convertToReceived(PurchaseOrder po, DateTime date) async {
    state = const AsyncLoading();
    final delieveredOrError =
        await ref.read(purchaseOrderServiceProvider).converteToReceived(purchaseOrderId: po.id!, date: date);
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

  Future<bool> delete(PurchaseOrder po) async {
    state = const AsyncLoading();
    final delieveredOrError = await ref.read(purchaseOrderServiceProvider).delete(po: po);
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

    Future<Either<String, ListResponse<PurchaseOrder>>> list({String? lastPurchaseOrderId}) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(purchaseOrderServiceProvider).list(lastPurchaseOrderId: lastPurchaseOrderId);
  }

  Future<Either<String, ListResponse<PurchaseOrder>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(purchaseOrderServiceProvider).list();
  }
}
