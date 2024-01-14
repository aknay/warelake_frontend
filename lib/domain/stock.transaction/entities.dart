import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:inventory_frontend/domain/item/entities.dart';

enum StockMovement { stockIn, stockOut, stockAdjust }

extension StockMovementExtension on StockMovement {
  String toFormattedString() {
    final exp = RegExp('(?<=[a-z])[A-Z]');
    return name.replaceAllMapped(exp, (m) => '_${m.group(0)}').toLowerCase();
  }

  String get description {
    switch (this) {
      case StockMovement.stockIn:
        return "Stock In";
      case StockMovement.stockOut:
        return "Stock Out";
      case StockMovement.stockAdjust:
        return "Stock Adjust";
      default:
        return "Unknown stock movement";
    }
  }

  static StockMovement fromFormattedString(String formattedString) {
    log("strin for is $formattedString");
    String enumString = _snakeCaseToCamelCase(formattedString);
    log("enum is $enumString");
    return StockMovement.values.firstWhere((e) => e.name == enumString);
  }

  static String _snakeCaseToCamelCase(String snakeCase) {
    List<String> parts = snakeCase.split('_');
    String camelCase = parts[0];

    for (int i = 1; i < parts.length; i++) {
      camelCase += parts[i][0].toUpperCase() + parts[i].substring(1);
    }

    return camelCase;
  }
}

class StockTransaction {
  String? id;
  String date;
  StockMovement stockMovement;
  String? updatedBy;
  List<StockLineItem> lineItems;
  String? notes;
  DateTime? createdTime;
  DateTime? modifiedAt;

  StockTransaction({
    this.id,
    required this.date,
    required this.stockMovement,
    this.updatedBy,
    required this.lineItems,
    this.notes,
    this.createdTime,
    this.modifiedAt,
  });

  factory StockTransaction.create(
      {required DateTime date, required List<StockLineItem> lineItems, required StockMovement stockMovement}) {
    final dateInString = DateFormat('yyyy-MM-dd').format(date);
    return StockTransaction(date: dateInString, lineItems: lineItems, stockMovement: stockMovement);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'stock_movement': stockMovement.toFormattedString(),
      'line_items': lineItems.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }

  static StockTransaction fromMap(Map<String, dynamic> json) {
    return StockTransaction(
        id: json['id'],
        date: json['date'],
        stockMovement: StockMovementExtension.fromFormattedString(json['stock_movement']),
        lineItems: List<StockLineItem>.from(json['line_items'].map((v) => StockLineItem.fromJson(v))),
        // lineItems: [],
        updatedBy: json['updated_by'],
        notes: json['notes'],
        createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null);
  }
}

class StockLineItem {
  ItemVariation itemVariation;
  int? itemId;
  int? lineItemId;
  String? description;
  int quantity;
  int? newStockLevel;
  int? oldStockLevel;

  StockLineItem(
      {this.itemId,
      required this.itemVariation,
      this.lineItemId,
      this.description,
      required this.quantity,
      this.newStockLevel,
      this.oldStockLevel});

  factory StockLineItem.create({required ItemVariation itemVariation, required int quantity}) {
    return StockLineItem(itemVariation: itemVariation, quantity: quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'item_variation': itemVariation.toJson(),
      'item_id': itemId,
      'line_item_id': lineItemId,
      'description': description,
      'quantity': quantity,
    };
  }

  static StockLineItem fromJson(Map<String, dynamic> json) {
    return StockLineItem(
      itemId: json['item_id'],
      itemVariation: ItemVariation.fromJson(json['item_variation']),
      lineItemId: json['line_item_id'],
      description: json['description'],
      quantity: json['quantity'],
      newStockLevel: json['new_stock_level'],
      oldStockLevel: json['old_stock_level'],
    );
  }
}
