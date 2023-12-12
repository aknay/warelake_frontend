import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.list.controller.g.dart';

@riverpod
class ItemListController extends _$ItemListController {
  @override
  Future<List<Item>> build() async {
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first;
  }

  Future<bool> createItem(Item item) async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(itemServiceProvider).createItem(item);
    return await createdOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      final itemsOrError = await _list();
      if (itemsOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(itemsOrError.toIterable().first);
      return true;
    });
  }

  Future<Either<String, List<Item>>> _list() async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(itemServiceProvider).list();
  }
}
