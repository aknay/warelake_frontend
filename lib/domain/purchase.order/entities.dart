import 'package:intl/intl.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/domain/item/entities.dart';

enum PurchaseOrderStatus {
  issued,
  received,
}

class PurchaseOrder {
  String? id;
  String? purchaseOrderNumber;
  String date;
  String? expectedDeliveryDate;
  String? referenceNumber;
  String status; // received, cancelled, partially_received
  int? vendorId;
  String? vendorName;
  int? contactPersons;
  String currencyCode;
  String? deliveryDate;
  List<LineItem> lineItems;
  int subTotal; //before tax
  int total; //after tax
  List<Tax>? taxes;
  int? pricePrecision;
  List<Address>? billingAddress;
  String? notes;
  String accountId;
  DateTime? createdTime;
  DateTime? modifiedAt;
  String? receivedAt;

  PurchaseOrder({
    this.id,
    this.purchaseOrderNumber,
    required this.date,
    this.expectedDeliveryDate,
    this.referenceNumber,
    required this.status,
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
    this.receivedAt,
  });

  factory PurchaseOrder.create(
      {required DateTime date,
      required CurrencyCode currencyCode,
      required List<LineItem> lineItems,
      required int subTotal,
      required int total,
      required String accountId,
      required String purchaseOrderNumber}) {
    final dateInString = DateFormat('yyyy-MM-dd').format(date);
    return PurchaseOrder(
        accountId: accountId,
        date: dateInString,
        status: "issued",
        currencyCode: currencyCode.name,
        lineItems: lineItems,
        subTotal: subTotal,
        total: total,
        purchaseOrderNumber: purchaseOrderNumber);
  }

  PurchaseOrderStatus get orderStatus => PurchaseOrderStatus.values.byName(status);

  double get totalInDouble => (total / 1000).toDouble();

  CurrencyCode get currencyCodeEnum => CurrencyCode.values.byName(currencyCode);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_number': purchaseOrderNumber,
      'date': date,
      'expectedDeliveryDate': expectedDeliveryDate,
      // 'referenceNumber': referenceNumber,
      'status': status,
      // 'vendorId': vendorId,
      // 'vendorName': vendorName,
      // 'contactPersons': contactPersons,
      'currency_code': currencyCode,
      // 'deliveryDate': deliveryDate,
      'line_items': lineItems.map((item) => item.toJson()).toList(),
      'sub_total': subTotal,
      'total': total,
      // 'taxes': taxes?.map((tax) => tax.toJson()).toList(),
      // 'pricePrecision': pricePrecision,
      // 'billingAddress': billingAddress?.map((address) => address.toJson()).toList(),
      'notes': notes,
      'account_id': accountId,
      // 'createdTime': createdTime?.toIso8601String(),
      // 'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  static PurchaseOrder fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      purchaseOrderNumber: json['purchase_order_number'],
      date: json['date'],
      // expectedDeliveryDate: json['expectedDeliveryDate'],
      // referenceNumber: json['referenceNumber'],
      status: json['status'],
      // vendorId: json['vendorId'],
      // vendorName: json['vendorName'],
      // contactPersons: json['contactPersons'],
      currencyCode: json['currency_code'],
      // deliveryDate: json['deliveryDate'],
      lineItems: List<LineItem>.from(json['line_items'].map((v) => LineItem.fromJson(v))),
      // lineItems: (json['line_items'] as List<LineItem>).map((item) => LineItem.fromJson(item)).toList(),
      subTotal: json['sub_total'],
      total: json['total'],
      // taxes: (json['taxes'] as List<dynamic>).map((tax) => Tax.fromJson(tax)).toList(),
      // pricePrecision: json['pricePrecision'],
      // billingAddress: (json['billingAddress'] as List<dynamic>).map((address) => Address.fromJson(address)).toList(),
      notes: json['notes'],
      accountId: json['account_id'],
      createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      receivedAt: json['received_at'],
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

class LineItem {
  ItemVariation itemVariation;
  int? itemId;
  int? lineItemId;
  String? description;
  int rate;
  int quantity;
  String unit;
  // int itemTotal;

  LineItem({
    this.itemId,
    required this.itemVariation,
    this.lineItemId,
    this.description,
    required this.rate,
    required this.quantity,
    required this.unit,
    // required this.itemTotal,
  });

  double get rateInDouble => (rate / 1000).toDouble();

  factory LineItem.create(
      {required ItemVariation itemVariation, required double rate, required int quantity, required String unit}) {
    return LineItem(itemVariation: itemVariation, rate: (rate * 1000).toInt(), quantity: quantity, unit: unit);
  }

  Map<String, dynamic> toJson() {
    return {
      'item_variation': itemVariation.toJson(),
      'item_id': itemId,
      'line_item_id': lineItemId,
      'description': description,
      'rate': rate,
      'quantity': quantity,
      'unit': unit,
      // 'itemTotal': itemTotal,
    };
  }

  static LineItem fromJson(Map<String, dynamic> json) {
    return LineItem(
      itemId: json['item_id'],
      itemVariation: ItemVariation.fromJson(json['item_variation']),
      lineItemId: json['line_item_id'],
      description: json['description'],
      rate: json['rate'],
      quantity: json['quantity'],
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
