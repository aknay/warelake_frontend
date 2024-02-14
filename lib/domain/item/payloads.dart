import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:warelake/domain/item/entities.dart';

class ItemUpdatePayload {
  String? name;
  String? unit;
  Option<List<ItemVariation>> newItemVariationListOrNone;
  ItemUpdatePayload({this.name, this.unit, this.newItemVariationListOrNone = const None()});

  //we w convert to a map before sending to the server
  Map<String, dynamic>? get variationsMapJson {
    if (newItemVariationListOrNone.isNone()) {
      return null;
    }
    final variations = newItemVariationListOrNone.toIterable().first;
    return variations.fold({}, (Map<String, dynamic>? map, ItemVariation variation) {
      final tempId = const Uuid().v4();
      map?[tempId] = variation.toJson();
      return map;
    });
  }

  Map<String, dynamic> toMap() {
    final f = variationsMapJson;
    return {'name': name, 'unit': unit, 'item_variations': f};
  }
}

class ItemVariationPayload {
  String? name;
  double? pruchasePrice;
  double? salePrice;
  ItemVariationPayload({this.name, this.pruchasePrice, this.salePrice});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchase_price': pruchasePrice == null ? pruchasePrice : (pruchasePrice! * 1000).toInt(),
      'sale_price': salePrice == null ? salePrice : (salePrice! * 1000).toInt(),
    };
  }
}
