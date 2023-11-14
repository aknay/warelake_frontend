class Item {
  String name;
  String? description;
  String? abbreviation;
  String? updatedAt;
  String? createdAt;
  List<ItemVariation> variations;
  String? productType;
  String unit;

  Item(
      {required this.name,
      this.description,
      this.abbreviation,
      required this.variations,
      this.productType,
      required this.unit});

  factory Item.create(
      {required String name, String? description, required List<ItemVariation> variations, required String unit}) {
    return Item(name: name, description: description, variations: variations, unit: unit);
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        name: json['name'],
        description: json['description'],
        abbreviation: json['abbreviation'],
        variations: List<ItemVariation>.from(json['item_variations'].map((v) => ItemVariation.fromJson(v))),
        productType: json['product_type'],
        unit: json['unit']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'abbreviation': abbreviation,
      'item_variations': variations.map((v) => v.toJson()).toList(),
      'product_type': productType,
      'unit': unit
    };
  }
}

class ItemVariation {
  String? type;
  String? id;
  String? createdAt;
  String? updatedAt;
  bool? isDeleted;
  String name;
  String? description;
  String? itemId; //parent id
  int? ordinal;
  String? pricingType;
  bool stockable;
  PriceMoney salePriceMoney;
  PriceMoney purchasePriceMoney;
  String sku;

  ItemVariation(
      {this.type,
      this.id,
      this.updatedAt,
      this.isDeleted,
      required this.name,
      required this.stockable,
      this.itemId,
      this.createdAt,
      required this.sku, required this.salePriceMoney, required this.purchasePriceMoney});

  factory ItemVariation.create({required String name, required bool stockable, required String sku, required PriceMoney salePriceMoney, required PriceMoney purchasePriceMoney}) {
    return ItemVariation(name: name, stockable: stockable, sku: sku, salePriceMoney: salePriceMoney, purchasePriceMoney: purchasePriceMoney);
  }

  factory ItemVariation.fromJson(Map<String, dynamic> json) {
    return ItemVariation(
      type: json['type'],
      id: json['item_variation_id'],
      itemId: json['item_id'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      isDeleted: json['is_deleted'],
      name: json['name'],
      stockable: json['stockable'],
      sku: json['sku'],
      salePriceMoney: PriceMoney.fromJson(json['sale_price_money']),
      purchasePriceMoney: PriceMoney.fromJson( json['purchase_price_money']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
      'name': name,
      'stockable': stockable,
      'sku' : sku,
      'sale_price_money' : salePriceMoney.toJson(),
      'purchase_price_money' : purchasePriceMoney.toJson()
    };
  }
}

class PriceMoney {
  int amount;
  String currency;

  PriceMoney({
    required this.amount,
    required this.currency,
  });

  factory PriceMoney.fromJson(Map<String, dynamic> json) {
    return PriceMoney(
      amount: json['amount'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}
