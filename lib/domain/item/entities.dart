class Item {
  String name;
  String? description;
  String? abbreviation;
  String? updatedAt;
  String? createdAt;
  List<ItemVariation> variations;
  String? productType;

  Item({
    required this.name,
    this.description,
    this.abbreviation,
    required this.variations,
    this.productType,
  });

  factory Item.create({required String name, String? description, required List<ItemVariation> variations}) {
    return Item(name: name, description: description, variations: variations);
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      description: json['description'],
      abbreviation: json['abbreviation'],
      variations: List<ItemVariation>.from(json['item_variations'].map((v) => ItemVariation.fromJson(v))),
      productType: json['product_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'abbreviation': abbreviation,
      'item_variations': variations.map((v) => v.toJson()).toList(),
      'product_type': productType,
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
  PriceMoney? priceMoney;

  ItemVariation({
    this.type,
    this.id,
    this.updatedAt,
    this.isDeleted,
    required this.name,
    required this.stockable,
    this.itemId,
    this.createdAt
  });

  factory ItemVariation.create({required String name, required bool stockable}) {
    return ItemVariation(name: name, stockable: stockable);
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
