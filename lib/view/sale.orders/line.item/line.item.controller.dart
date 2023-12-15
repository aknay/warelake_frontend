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
  }

  void remove(String todoId) {
    // Again, our state is immutable. So we're making a new list instead of
    // changing the existing list.
    state = [
      for (final todo in state)
        if (todo.itemVariation.id != todoId) todo,
    ];
  }
}
