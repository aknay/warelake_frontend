class PayloadItem {
  String? name;
  PayloadItem({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
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
