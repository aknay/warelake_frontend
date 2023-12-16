import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:inventory_frontend/data/bill.account/bill.account.service.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill.account.controller.g.dart';

@riverpod
class BillAccountListController extends _$BillAccountListController {
  @override
  Future<List<BillAccount>> build() async {
    final billAccountsOrError = await _list();
    if (billAccountsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return billAccountsOrError.toIterable().first;
  }

  Future<Either<String, List<BillAccount>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(billAccountServiceProvider).list();
  }
}
