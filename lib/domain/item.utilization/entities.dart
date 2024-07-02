import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:warelake/domain/common/entities.dart';

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
  double? itemCount;
  String? barcode;
  String? imageUrl;
  Option<int> minimumStockCountOrNone;
  Option<DateTime> expiryDate;

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
      this.minimumStockCountOrNone = const None(),
      this.expiryDate = const None()});

  factory ItemVariation.create(
      {required String name,
      required bool stockable,
      required String sku,
      required PriceMoney salePriceMoney,
      required PriceMoney purchasePriceMoney,
      double? itemCount,
      String? barcode,
      Option<int> minimumStock = const None(),
      Option<DateTime> expiryDate = const None()}) {
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
        minimumStockCountOrNone: minimumStock,
        expiryDate: expiryDate);
  }

  ItemVariation copyWith(
      {String? name,
      bool? stockable,
      String? sku,
      PriceMoney? salePriceMoney,
      PriceMoney? purchasePriceMoney,
      double? itemCount,
      String? barcode,
      Option<int> minimumStockCountOrNone = const None(),
      Option<DateTime> expiryDate = const None()}) {
    return ItemVariation(
        id: id,
        stockable: stockable ?? this.stockable,
        name: name ?? this.name,
        sku: sku ?? this.sku,
        salePriceMoney: salePriceMoney ?? this.salePriceMoney,
        purchasePriceMoney: purchasePriceMoney ?? this.purchasePriceMoney,
        itemCount: itemCount ?? this.itemCount,
        barcode: barcode ?? this.barcode,
        minimumStockCountOrNone: minimumStockCountOrNone,
        expiryDate: expiryDate);
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
        itemCount: (json['item_count'] as num).toDouble(),
        barcode: json['barcode'],
        imageUrl: json['image_url'],
        minimumStockCountOrNone: json['minimum_stock_count'] == 0 ? const None() : Some(json['minimum_stock_count']),
        expiryDate: json['expiry_date'] == null ? const None() : Some(DateTime.parse(json['expiry_date']).toLocal()));
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
      'minimum_stock_count': minimumStockCountOrNone.fold(() => null, (a) => a),
      'expiry_date': expiryDate.fold(() => null, (a) => a.toUtc().toIso8601String())
    };
  }
}