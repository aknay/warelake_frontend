import 'package:intl/intl.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/domain/item/entities.dart';

class SaleOrder {
  String? id;
  String? purchaseOrderNumber;
  String date;
  String? expectedDeliveryDate;
  String? referenceNumber;
  String? status; // received, cancelled, partially_received
  int? vendorId;
  String? vendorName;
  int? contactPersons;
  String currencyCode;
  String? deliveryDate;
  List<SaleLineItem> lineItems;
  int subTotal; //before tax
  int total; //after tax
  List<Tax>? taxes;
  int? pricePrecision;
  List<Address>? billingAddress;
  String? notes;
  String accountId;
  DateTime? createdTime;
  DateTime? modifiedAt;

  SaleOrder({
    this.id,
    this.purchaseOrderNumber,
    required this.date,
    this.expectedDeliveryDate,
    this.referenceNumber,
    this.status,
    this.vendorId,
    this.vendorName,
    this.contactPersons,
    required this.currencyCode,
    this.deliveryDate,
    required this.lineItems,
    required this.subTotal,
    required this.total,
    this.taxes,
    this.pricePrecision,
    this.billingAddress,
    this.notes,
    required this.accountId,
    this.createdTime,
    this.modifiedAt,
  });

  factory SaleOrder.create(
      {required DateTime date,
      required CurrencyCode currencyCode,
      required List<SaleLineItem> lineItems,
      required int subTotal,
      required int total,
      required String accountId}) {
    final dateInString = DateFormat('yyyy-MM-dd').format(date);
    return SaleOrder(
        accountId: accountId,
        date: dateInString,
        currencyCode: currencyCode.name,
        lineItems: lineItems,
        subTotal: subTotal,
        total: total);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseorder_number': purchaseOrderNumber,
      'date': date,
      'expectedDeliveryDate': expectedDeliveryDate,
      'status': status,
      'currency_code': currencyCode,
      'line_items': lineItems.map((item) => item.toJson()).toList(),
      'sub_total': subTotal,
      'total': total,
      'notes': notes,
      'account_id': accountId,
    };
  }

  static SaleOrder fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      id: json['id'],
      purchaseOrderNumber: json['purchaseorder_number'],
      date: json['date'],
      status: json['status'],
      currencyCode: json['currency_code'],
      lineItems: List<SaleLineItem>.from(json['line_items'].map((v) => SaleLineItem.fromJson(v))),
      subTotal: json['sub_total'],
      total: json['total'],
      notes: json['notes'],
      accountId: json['account_id'],
      createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

class Address {
  String address;
  String city;
  String state;
  int zip;
  String country;
  String fax;

  Address({
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.fax,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'fax': fax,
    };
  }

  static Address fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
      fax: json['fax'],
    );
  }
}

class SaleLineItem {
  ItemVariation itemVariation;
  int? itemId;
  int? lineItemId;
  String? description;
  int saleRate;
  int saleQuantity;
  String unit;
  // int itemTotal;

  SaleLineItem({
    this.itemId,
    required this.itemVariation,
    this.lineItemId,
    this.description,
    required this.saleRate,
    required this.saleQuantity,
    required this.unit,
    // required this.itemTotal,
  });

  factory SaleLineItem.create(
      {required ItemVariation itemVariation,
      required double purchaseRate,
      required int purchaseQuantity,
      required String unit}) {
    return SaleLineItem(
        itemVariation: itemVariation, saleRate: (purchaseRate * 1000).toInt(), saleQuantity: purchaseQuantity, unit: unit);
  }

  Map<String, dynamic> toJson() {
    return {
      'item_variation': itemVariation.toJson(),
      'item_id': itemId,
      'line_item_id': lineItemId,
      'description': description,
      'sale_rate': saleRate,
      'sale_quantity': saleQuantity,
      'unit': unit,
      // 'itemTotal': itemTotal,
    };
  }

  static SaleLineItem fromJson(Map<String, dynamic> json) {
    return SaleLineItem(
      itemId: json['item_id'],
      itemVariation: ItemVariation.fromJson(json['item_variation']),
      lineItemId: json['line_item_id'],
      description: json['description'],
      saleRate: json['sale_rate'],
      saleQuantity: json['sale_quantity'],
      unit: json['unit'],
      // itemTotal: json['itemTotal'],
    );
  }
}

class Tax {
  String taxName;
  int taxAmount;

  Tax({
    required this.taxName,
    required this.taxAmount,
  });
  Map<String, dynamic> toJson() {
    return {
      'taxName': taxName,
      'taxAmount': taxAmount,
    };
  }

  static Tax fromJson(Map<String, dynamic> json) {
    return Tax(
      taxName: json['taxName'],
      taxAmount: json['taxAmount'],
    );
  }
}
