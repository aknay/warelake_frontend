import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:inventory_frontend/data/purchase.order/purchase.order.service.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase.order.list.controller.g.dart';

@riverpod
class PurchaseOrderListController extends _$PurchaseOrderListController {
  @override
  Future<List<PurchaseOrder>> build() async {
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first;
  }

  Future<Either<String, List<PurchaseOrder>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(purchaseOrderServiceProvider).list();
  }
}
