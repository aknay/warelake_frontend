import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/purchase.order/entities.dart';

enum SaleOrderStatus {
  issued,
  delivered,
}

class SaleOrder {
  String? id;
  String? saleOrderNumber;
  DateTime date;
  String? expectedDeliveryDate;
  String? referenceNumber;
  String? status; // received, cancelled, partially_received
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
  DateTime? deliveredAt;

  SaleOrder({
    this.id,
    this.saleOrderNumber,
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
    this.deliveredAt,
  });

  SaleOrderStatus get saleOrderStatus => SaleOrderStatus.values.byName(status!);

  factory SaleOrder.create(
      {required DateTime date,
      required CurrencyCode currencyCode,
      required List<LineItem> lineItems,
      required int subTotal,
      required int total,
      required String accountId,
      required String saleOrderNumber}) {
    return SaleOrder(
        accountId: accountId,
        date: date,
        currencyCode: currencyCode.name,
        lineItems: lineItems,
        subTotal: subTotal,
        total: total,
        saleOrderNumber: saleOrderNumber);
  }

  double get totalInDouble => (total / 1000).toDouble();

  CurrencyCode get currencyCodeEnum => CurrencyCode.values.byName(currencyCode);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_order_number': saleOrderNumber,
      'date': date.toUtc().toIso8601String(),
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
        saleOrderNumber: json['sale_order_number'],
        date: DateTime.parse(json['date']).toLocal(),
        status: json['status'],
        currencyCode: json['currency_code'],
        lineItems: List<LineItem>.from(json['line_items'].map((v) => LineItem.fromJson(v))),
        subTotal: json['sub_total'],
        total: json['total'],
        notes: json['notes'],
        accountId: json['account_id'],
        createdTime: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        modifiedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null);
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
