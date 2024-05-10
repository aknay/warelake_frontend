import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/valueobject.dart';

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
  int? itemCount;
  String? barcode;
  String? imageUrl;
  Option<int> minimumStockCountOrNone;

  ItemVariation(
      {this.type,
      this.id,
      this.updatedAt,
      this.isDeleted,
      required this.name,
      required this.stockable,
      this.itemId,
      this.createdAt,
      required this.sku,
      required this.salePriceMoney,
      required this.purchasePriceMoney,
      this.itemCount,
      this.barcode,
      this.imageUrl,
      this.minimumStockCountOrNone = const None()});

  factory ItemVariation.create(
      {required String name,
      required bool stockable,
      required String sku,
      required PriceMoney salePriceMoney,
      required PriceMoney purchasePriceMoney,
      int? itemCount,
      String? barcode,
      Option<int> minimumStock = const None()}) {
    var uuid = const Uuid();
    String newUuid = uuid.v4();

    return ItemVariation(
        id: newUuid,
        name: name,
        stockable: stockable,
        sku: sku,
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        itemCount: itemCount,
        barcode: barcode,
        minimumStockCountOrNone: minimumStock);
  }

  ItemVariation copyWith(
      {String? name,
      bool? stockable,
      String? sku,
      PriceMoney? salePriceMoney,
      PriceMoney? purchasePriceMoney,
      int? itemCount,
      String? barcode,
      Option<int> minimumStockCountOrNone = const None()}) {
    return ItemVariation(
        id: id,
        stockable: stockable ?? this.stockable,
        name: name ?? this.name,
        sku: sku ?? this.sku,
        salePriceMoney: salePriceMoney ?? this.salePriceMoney,
        purchasePriceMoney: purchasePriceMoney ?? this.purchasePriceMoney,
        itemCount: itemCount ?? this.itemCount,
        barcode: barcode ?? this.barcode,
        minimumStockCountOrNone: minimumStockCountOrNone);
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
        salePriceMoney: PriceMoney.fromJson(json['sale_price']),
        purchasePriceMoney: PriceMoney.fromJson(json['purchase_price']),
        itemCount: json['item_count'],
        barcode: json['barcode'],
        imageUrl: json['image_url'],
        minimumStockCountOrNone: json['minimum_stock_count'] == 0 ? const None() : Some(json['minimum_stock_count']));
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'item_variation_id': id,
      'item_id': itemId,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
      'name': name,
      'stockable': stockable,
      'sku': sku,
      'sale_price': salePriceMoney.toJson(),
      'purchase_price': purchasePriceMoney.toJson(),
      'barcode': barcode,
      'minimum_stock_count': minimumStockCountOrNone.fold(() => null, (a) => a)
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

  Amount get amountInDouble => (amount / 1000).toDouble();

  factory PriceMoney.from({required double amount, required CurrencyCode currencyCode}) {
    return PriceMoney(amount: (amount * 1000).toInt(), currency: currencyCode.name);
  }

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

class ItemUtilization {
  int totalItemVariationsCount;
  int totalItemCount;
  int totalQuantityOfAllItemVariation;

  ItemUtilization(
      {required this.totalItemVariationsCount,
      required this.totalItemCount,
      required this.totalQuantityOfAllItemVariation});

  factory ItemUtilization.fromMap(Map<String, dynamic> json) {
    return ItemUtilization(
      totalItemVariationsCount: json['total_item_variations_count'],
      totalItemCount: json['total_item_count'],
      totalQuantityOfAllItemVariation: json['total_quantity_of_all_item_variation'],
    );
  }
}
