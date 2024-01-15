import 'dart:developer';

import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'line.item.controller.g.dart';

@riverpod
class LineItemController extends _$LineItemController {
  @override
  List<LineItem> build() {
    return [];
  }

  void add(LineItem lineItem) {
    state = [...state, lineItem];
    log("the state ${state.length}");
  }

  void remove({required String lineItemId}) {
    state = [
      for (final todo in state)
        if (todo.itemVariation.id != lineItemId) todo,
    ];
  }
}
