import 'dart:developer';

import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock.line.item.controller.g.dart';

@riverpod
class StockLineItemController extends _$StockLineItemController {
  @override
  List<StockLineItem> build() {
    return [];
  }

  void add(StockLineItem lineItem) {
    state = [...state, lineItem];
    log("the state ${state.length}");
  }

  void remove(String itemVariationId) {
    state = [
      for (final todo in state)
        if (todo.itemVariation.id != itemVariationId) todo,
    ];
  }

  void edit({required String itemVariationId, required int value}){

    StockLineItem setValueToItemIfFound(StockLineItem item ){
      if( item.itemVariation.id == itemVariationId){
         item.quantity = value;
         return item;
      }
      return item;
    }


   state = state.map((e) => setValueToItemIfFound(e)).toList();

    // for (var element in state) { 



    // }
    //     state = [
    //   for (final todo in state)
    //     if (todo.itemVariation.id != itemVariationId) {
    //       todo.quantity = value; 
    //       return todo
    //       }
    // ];
  }
}
