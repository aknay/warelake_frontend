import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';
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
      //we cannot update here as no widget is listing item list controller 
      // state = AsyncValue.data(itemsOrError.toIterable().first.data);
      return true;
    });
  }

  // Future<void> search(String text) async {
  //   if (text.length > 2) {
  //     state = const AsyncLoading();
  //     final itemsOrError = await _list(searchField: ItemSearchField(itemName: text));
  //     if (itemsOrError.isLeft()) {
  //       throw AssertionError("error while fetching items");
  //     }
  //     state = AsyncValue.data(itemsOrError.toIterable().first.data);
  //   } else if (text.isEmpty) {
  //     state = const AsyncLoading();
  //     final itemsOrError = await _list();
  //     if (itemsOrError.isLeft()) {
  //       throw AssertionError("error while fetching items");
  //     }
  //     state = AsyncValue.data(itemsOrError.toIterable().first.data);
  //   }
  // }

  // Future<Either<String, ListResponse<Item>>> list({String? searchText, String? startingAfterItemId}) async {
  //   log("call this?");
  //   final textToSearch = searchText != null && searchText.length > 2 ? searchText : null;
  //   final searchField = ItemSearchField(itemName: textToSearch, startingAfterItemId: startingAfterItemId);
  //   return ref.read(itemServiceProvider).list(itemSearchField: searchField);
  // }

  Future<Either<String, ListResponse<Item>>> _list({ItemSearchField? searchField}) async {
    log("call this _list?");
    if (foundation.kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    // return Right(ListResponse(data: [], hasMore: false));
    return await ref.read(itemServiceProvider).list(itemSearchField: searchField);
  }
}
