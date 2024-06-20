import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:warelake/domain/item/entities.dart';

class ItemUpdatePayload {
  String? name;
  String? unit;
  List<ItemVariation> newItemVariationListOrNone;

  ItemUpdatePayload({this.name, this.unit, this.newItemVariationListOrNone = const []});

  //we w convert to a map before sending to the server
  Map<String, dynamic>? get variationsMapJson {
    if (newItemVariationListOrNone.isEmpty) {
      return null;
    }
    final variations = newItemVariationListOrNone;
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

class ExpiryDateOrDisable {
  Option<DateTime> expiryDate;
  bool disableExpiryDate;

  ExpiryDateOrDisable({this.expiryDate = const None(), this.disableExpiryDate = false});

  factory ExpiryDateOrDisable.disableExpiryDate() {
    return ExpiryDateOrDisable(expiryDate: const None(), disableExpiryDate: true);
  }

  factory ExpiryDateOrDisable.updateExpiryDate(DateTime dateTime) {
    return ExpiryDateOrDisable(expiryDate: Some(dateTime), disableExpiryDate: false);
  }

  Map<String, dynamic> toMap() {
    return {
      'expiry_date_or_null': expiryDate.fold(() => null, (a) => a.toUtc().toIso8601String()),
      'disable_expiry_date': disableExpiryDate
    };
  }
}

class ItemVariationPayload {
  String? name;
  double? pruchasePrice;
  double? salePrice;
  String? barcode;
  Option<int> minimumStockOrNone;

  Option<ExpiryDateOrDisable> expiryDateOrDisable;

  ItemVariationPayload({
    this.name,
    this.pruchasePrice,
    this.salePrice,
    this.barcode,
    this.minimumStockOrNone = const None(),
    this.expiryDateOrDisable = const None(),
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchase_price': pruchasePrice == null ? pruchasePrice : (pruchasePrice! * 1000).toInt(),
      'sale_price': salePrice == null ? salePrice : (salePrice! * 1000).toInt(),
      'barcode': barcode,
      'minimum_stock_count': minimumStockOrNone.fold(() => null, (a) => a),
      'expiry_date_or_disable': expiryDateOrDisable.fold(() => null, (a) => a.toMap())
    };
  }
}
