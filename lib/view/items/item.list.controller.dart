import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

part 'item.list.controller.g.dart';

@riverpod
class ItemListController extends _$ItemListController {
  @override
  Future<List<Item>> build() async {
    final itemsOrError = await _list();
    if (itemsOrError.isLeft()) {
      throw AssertionError("error while fetching items");
    }
    return itemsOrError.toIterable().first.data;
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
      state = AsyncValue.data(itemsOrError.toIterable().first.data);
      return true;
    });
  }


  Future<Either<String, ListResponse<Item>>> _list({ItemSearchField? searchField}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    // return Right(ListResponse(data: [], hasMore: false));
    return await ref.read(itemServiceProvider).list(itemSearchField: searchField);
  }
}
