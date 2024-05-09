import 'package:flutter/foundation.dart';
import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.variation.controller.g.dart';

@riverpod
class ItemVariationController extends _$ItemVariationController {
  
  
  @override
  Future<ItemVariation> build({required String itemId, required String itemVariationId}) {
    return _getItem(itemId: itemId, itemVariationId: itemVariationId);
  }

   Future<ItemVariation> _getItem({required String itemId, required String itemVariationId}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final itemOrError = await ref.read(itemServiceProvider).getItemVariation(itemId: itemId, itemVariationId: itemVariationId);
    if (itemOrError.isRight()) {
      return itemOrError.toIterable().first;
    }
    throw Exception('unable to get item utilization');
  }

}
