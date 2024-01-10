class ItemUpdatePayload {
  String? name;
  String? unit;
  ItemUpdatePayload({this.name, this.unit});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit' : unit
    };
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
