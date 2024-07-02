import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/domain/item.utilization/entities.dart';

part 'item.variation.list.controller.g.dart';

@riverpod
class ItemVariationListController extends _$ItemVariationListController {
  @override
  List<ItemVariation> build() {
    return [];
  }

  void upset(ItemVariation value) {
    final isAlreadyInTheList = state.where((element) => element.id == value.id).isNotEmpty;
    if (isAlreadyInTheList) {
      state = [...state.where((element) => element.id != value.id), value];
    } else {
      state = [...state, value];
    }
  }

  void delete(ItemVariation value) {
    state = state.where((element) => element.id != value.id).toList();
  }
}
