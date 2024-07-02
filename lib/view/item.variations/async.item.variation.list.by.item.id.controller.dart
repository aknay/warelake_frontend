import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/item.variation/item.variation.service.dart';
import 'package:warelake/domain/item.utilization/entities.dart';

part 'async.item.variation.list.by.item.id.controller.g.dart';

@riverpod
class AsyncItemVariationListByItemIdController
    extends _$AsyncItemVariationListByItemIdController {
  @override
  Future<List<ItemVariation>> build({required String itemId}) {
    return _getItemVariations(itemId: itemId);
  }

  Future<List<ItemVariation>> _getItemVariations(
      {required String itemId}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final itemOrError = await ref
        .read(itemVariationServiceProvider)
        .getItemVariations(itemId: itemId);
    if (itemOrError.isRight()) {
      return itemOrError.toIterable().first;
    }
    throw Exception('unable to get item utilization');
  }
}
