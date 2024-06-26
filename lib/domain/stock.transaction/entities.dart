import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:warelake/domain/item.utilization/entities.dart';

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
  DateTime date;
  StockMovement stockMovement;
  String? updatedBy;
  List<StockLineItem> lineItems;
  Option<String> notes;
  DateTime? createdTime;
  DateTime? modifiedAt;

  StockTransaction({
    this.id,
    required this.date,
    required this.stockMovement,
    this.updatedBy,
    required this.lineItems,
    this.notes = const None(),
    this.createdTime,
    this.modifiedAt,
  });

  factory StockTransaction.create(
      {required DateTime date,
      required List<StockLineItem> lineItems,
      required StockMovement stockMovement,
      Option<String> notes = const None()}) {
    return StockTransaction(
        date: date, lineItems: lineItems, stockMovement: stockMovement, createdTime: date, notes: notes);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toUtc().toIso8601String(),
      'stock_movement': stockMovement.toFormattedString(),
      'line_items': lineItems.map((item) => item.toJson()).toList(),
      'notes': notes.fold(() => null, (a) => a),
      'created_at': createdTime?.toUtc().toIso8601String()
    };
  }

  static StockTransaction fromMap(Map<String, dynamic> json) {
    return StockTransaction(
        id: json['id'],
        date: DateTime.parse(json['date']).toLocal(),
        stockMovement: StockMovementExtension.fromFormattedString(json['stock_movement']),
        lineItems: List<StockLineItem>.from(json['line_items'].map((v) => StockLineItem.fromJson(v))),
        updatedBy: json['updated_by'],
        notes: json['notes'] == null ? const None() : Some(json['notes']),
        createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
        modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null);
  }
}

class StockLineItem {
  ItemVariation itemVariation;
  int? itemId;
  int? lineItemId;
  String? description;
  double quantity;
  double? newStockLevel;
  double? oldStockLevel;

  StockLineItem(
      {this.itemId,
      required this.itemVariation,
      this.lineItemId,
      this.description,
      required this.quantity,
      this.newStockLevel,
      this.oldStockLevel});

  factory StockLineItem.create({required ItemVariation itemVariation, required double quantity}) {
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
    //ref: https://stackoverflow.com/a/20135063
    // json['quantity'] will be either intger for 5.0 and float for 5.6. so need to convert it to float
    return StockLineItem(
      itemId: json['item_id'],
      itemVariation: ItemVariation.fromJson(json['item_variation']),
      lineItemId: json['line_item_id'],
      description: json['description'],
      quantity: (json['quantity'] as num).toDouble(),
      newStockLevel: (json['new_stock_level'] as num).toDouble(),
      oldStockLevel: (json['old_stock_level'] as num).toDouble(),
    );
  }
}
