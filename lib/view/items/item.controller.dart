import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/item.variation/item.variation.service.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item.variation/payloads.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/view/items/item.list.view.dart';
import 'package:warelake/view/routing/app.router.dart';

part 'item.controller.g.dart';

@riverpod
class ItemController extends _$ItemController {
  @override
  Future<Item> build({required String itemId}) {
    return _getItem(itemId: itemId);
  }

  Future<Unit> deleteItem() async {
    state = const AsyncLoading();
    final createdOrError = await ref.read(itemServiceProvider).deleteItem(itemId: itemId);
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    return await createdOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return unit;
    }, (r) async {
      ref.read(toForceToRefreshIemListProvider.notifier).state = !ref.read(toForceToRefreshIemListProvider);
      ref.read(goRouterProvider).pop();
      return unit;
    });
  }

  Future<Unit> deleteItemVariation({required String itemVariationId}) async {
    state = const AsyncValue.loading();
    final deletedOrError = await ref
        .read(itemVariationServiceProvider)
        .deleteItemVariation(itemId: itemId, itemVariationId: itemVariationId);
    if (deletedOrError.isLeft()) {
      throw Exception('unable to delete item variation');
    }
    state = AsyncValue.data(await _getItem(itemId: itemId));
    //ref: https://codewithandrea.com/articles/flutter-navigate-without-context-gorouter-riverpod/
    ref.read(goRouterProvider).pop();
    return unit;
  }

  Future<Unit> updateItemVariation({required String itemVariationId, required ItemVariationPayload payload}) async {
    state = const AsyncLoading();

    final updatedOrError = await ref
        .read(itemVariationServiceProvider)
        .updateItemVariation(payload: payload, itemId: itemId, itemVariationId: itemVariationId);
    return await updatedOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return unit;
    }, (r) async {
      state = AsyncValue.data(await _getItem(itemId: itemId));
      return unit;
    });
  }

  Future<Item> _getItem({required String itemId}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final itemOrError = await ref.read(itemServiceProvider).getItem(itemId: itemId);
    if (itemOrError.isRight()) {
      return itemOrError.toIterable().first;
    }
    throw Exception('unable to get item utilization');
  }

  Future<bool> updateItem({required ItemUpdatePayload payload}) async {
    state = const AsyncLoading();
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final createdOrError = await ref.read(itemServiceProvider).updateItem(payload: payload, itemId: itemId);

    return await createdOrError.fold((l) {
      state = AsyncError(l, StackTrace.current);
      return false;
    }, (r) async {
      state = AsyncValue.data(await _getItem(itemId: itemId));
      return true;
    });
  }
}
