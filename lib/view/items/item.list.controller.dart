import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:inventory_frontend/domain/item/search.fields.dart';
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

  Future<bool> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
  }) async {
    state = const AsyncLoading();
    final createdOrError = await ref
        .read(itemServiceProvider)
        .updateItemVariation(payload: payload, itemId: itemId, itemVariationId: itemVariationId);
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

  Future<bool> updateItem({required ItemUpdatePayload payload, required String itemId}) async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(itemServiceProvider).updateItem(payload: payload, itemId: itemId);
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

  Future<void> search(String text) async {
    if (text.length > 2) {
      state = const AsyncLoading();
      final itemsOrError = await _list(searchField: ItemSearchField(itemName: text));
      if (itemsOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(itemsOrError.toIterable().first);
    } else if (text.isEmpty){
       state = const AsyncLoading();
             final itemsOrError = await _list();
      if (itemsOrError.isLeft()) {
        throw AssertionError("error while fetching items");
      }
      state = AsyncValue.data(itemsOrError.toIterable().first);
    }
  }

  Future<Either<String, List<Item>>> _list({ItemSearchField? searchField}) async {
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await ref.read(itemServiceProvider).list(itemSearchField: searchField);
  }
}
