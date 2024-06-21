
class Item {
  String? id;
  String name;
  String? description;
  String? abbreviation;
  String? updatedAt;
  String? createdAt;
  String? productType;
  String unit;
  String? imageUrl;

  Item(
      {required this.name,
      this.description,
      this.abbreviation,
      this.productType,
      required this.unit,
      this.id,
      this.imageUrl});

  factory Item.create({required String name, String? description, required String unit}) {
    return Item(name: name, description: description, unit: unit);
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['item_id'],
        name: json['name'],
        description: json['description'],
        abbreviation: json['abbreviation'],
        productType: json['product_type'],
        unit: json['unit'],
        imageUrl: json['image_url']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'abbreviation': abbreviation,
      'product_type': productType,
      'unit': unit
    };
  }
}





class ItemUtilization {
  int totalItemVariationsCount;
  int totalItemCount;
  double totalQuantityOfAllItemVariation;

  ItemUtilization(
      {required this.totalItemVariationsCount,
      required this.totalItemCount,
      required this.totalQuantityOfAllItemVariation});

  factory ItemUtilization.fromMap(Map<String, dynamic> json) {
    // so that it will take care of rounding due to floating point
    final totalQuantityOfAllItemVariationInRawDouble = (json['total_quantity_of_all_item_variation'] as num).toDouble();
    final totalQuantityOfAllItemVariationAfterDoubleFixed =
        double.parse(totalQuantityOfAllItemVariationInRawDouble.toStringAsFixed(10));
    return ItemUtilization(
      totalItemVariationsCount: json['total_item_variations_count'],
      totalItemCount: json['total_item_count'],
      totalQuantityOfAllItemVariation: totalQuantityOfAllItemVariationAfterDoubleFixed,
    );
  }
}
