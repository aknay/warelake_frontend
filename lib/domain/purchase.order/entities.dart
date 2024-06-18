import 'package:dartz/dartz.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';

class PurchaseOrder {
  String? id;
  String? purchaseOrderNumber;
  DateTime date;
  String? expectedDeliveryDate;
  String? referenceNumber;
  Option<PurchaseOrderStatus> status; // received, cancelled, partially_received
  int? vendorId;
  String? vendorName;
  int? contactPersons;
  String currencyCode;
  String? deliveryDate;
  List<LineItem> lineItems;
  double subTotal; //before tax
  double total; //after tax
  List<Tax>? taxes;
  int? pricePrecision;
  List<Address>? billingAddress;
  Option<String> notes;
  String accountId;
  DateTime? createdTime;
  DateTime? modifiedAt;
  DateTime? receivedAt;

  PurchaseOrder({
    this.id,
    this.purchaseOrderNumber,
    required this.date,
    this.expectedDeliveryDate,
    this.referenceNumber,
    this.status = const None(),
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
    this.notes = const None(),
    required this.accountId,
    this.createdTime,
    this.modifiedAt,
    this.receivedAt,
  });

  factory PurchaseOrder.create(
      {required DateTime date,
      required CurrencyCode currencyCode,
      required List<LineItem> lineItems,
      required double subTotal,
      required double total,
      required String accountId,
      required String purchaseOrderNumber,
      Option<String> notes = const None()}) {
    return PurchaseOrder(
        accountId: accountId,
        date: date,
        currencyCode: currencyCode.name,
        lineItems: lineItems,
        subTotal: subTotal,
        total: total,
        purchaseOrderNumber: purchaseOrderNumber,
        notes: notes);
  }

  // PurchaseOrderStatus get orderStatus => PurchaseOrderStatus.values.byName(status);

  double get totalInDouble => (total / 1000).toDouble();

  CurrencyCode get currencyCodeEnum => CurrencyCode.values.byName(currencyCode);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_number': purchaseOrderNumber,
      'date': date.toUtc().toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate,
      // 'referenceNumber': referenceNumber,
      // 'status': status,
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
      'notes': notes.fold(() => null, (a) => a),
      'account_id': accountId,
      // 'createdTime': createdTime?.toIso8601String(),
      // 'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  static PurchaseOrder fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      purchaseOrderNumber: json['purchase_order_number'],
      date: DateTime.parse(json['date']).toLocal(),
      // expectedDeliveryDate: json['expectedDeliveryDate'],
      // referenceNumber: json['referenceNumber'],
      status: json['status'] == null ? const None() : Some(PurchaseOrderStatus.values.byName(json['status'])),
      // vendorId: json['vendorId'],
      // vendorName: json['vendorName'],
      // contactPersons: json['contactPersons'],
      currencyCode: json['currency_code'],
      // deliveryDate: json['deliveryDate'],
      lineItems: List<LineItem>.from(json['line_items'].map((v) => LineItem.fromJson(v))),
      // lineItems: (json['line_items'] as List<LineItem>).map((item) => LineItem.fromJson(item)).toList(),
      subTotal: (json['sub_total'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      // taxes: (json['taxes'] as List<dynamic>).map((tax) => Tax.fromJson(tax)).toList(),
      // pricePrecision: json['pricePrecision'],
      // billingAddress: (json['billingAddress'] as List<dynamic>).map((address) => Address.fromJson(address)).toList(),
      notes: optionOf(json['notes']),
      accountId: json['account_id'],
      createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
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
  double quantity;
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
  double get totalAmount => rateInDouble * quantity;

  factory LineItem.create(
      {required ItemVariation itemVariation, required double rate, required double quantity, required String unit}) {
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
    };
  }

  static LineItem fromJson(Map<String, dynamic> json) {
    return LineItem(
      itemId: json['item_id'],
      itemVariation: ItemVariation.fromJson(json['item_variation']),
      lineItemId: json['line_item_id'],
      description: json['description'],
      rate: json['rate'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
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
