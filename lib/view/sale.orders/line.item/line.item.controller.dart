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
    final newList = state.where((element) => element.itemVariation.id != lineItem.itemVariation.id);
    state = [...newList, lineItem];
  }

  void remove({required LineItem lineItem}) {
    state = [
      for (final lineItem in state)
        if (lineItem.itemVariation.id != lineItem.itemVariation.id) lineItem,
    ];
  }
}
