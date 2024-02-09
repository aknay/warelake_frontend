import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:warelake/data/stock.transaction/stock.transaction.service.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock.transaction.list.controller.g.dart';

@riverpod
class StockTransactionListController extends _$StockTransactionListController {
  @override
  Future<List<StockTransaction>> build() async {
    // return [];
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first.data;
  }

  Future<bool> create(StockTransaction stockTransaction) async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(stockTransactionServiceProvider).create(stockTransaction);
    return await createdOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final itemsOrError = await _list();
      if (itemsOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(itemsOrError.toIterable().first.data);
      return true;
    });
  }

    Future<bool> delete(StockTransaction stockTransaction) async {
    state = const AsyncLoading();
    final deletedOrError = await ref.read(stockTransactionServiceProvider).delete(stockTransaction);
    return await deletedOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final itemsOrError = await _list();
      if (itemsOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(itemsOrError.toIterable().first.data);
      return true;
    });
  }

  Future<Either<String, ListResponse<StockTransaction>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(stockTransactionServiceProvider).list();
  }
}
