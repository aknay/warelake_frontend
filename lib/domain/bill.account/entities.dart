import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/domain/valueobject.dart';

class BillAccount {
  String? id;
  DateTime? createdAt;
  final String name;
  final String type;
  String? description;
  final String status;
  final MilliAmount? milliBalance;
  final MilliAmount initialMilliBalance;
  final String currencyCode;

  BillAccount(
      {required this.name,
      required this.type,
      required this.status,
      this.milliBalance,
      required this.currencyCode,
      this.description,
      this.createdAt,
      this.id,
      required this.initialMilliBalance});

  factory BillAccount.create(
      {required AccountType accountType,
      required String name,
      String? description,
      required Amount initialBalance,
      required bool isOnBudget,
      required CurrencyCode currencyCode}) {
    return BillAccount(
        type: accountType.name,
        name: name,
        description: description,
        status: AccountStatus.opened.name,
        initialMilliBalance: (initialBalance * 1000).toInt(),
        currencyCode: currencyCode.name);
  }

  Amount get totalBalance => ((initialMilliBalance + milliBalance!) / 1000);
  Amount get intialBalance => ((initialMilliBalance) / 1000);
  Amount get balance => ((milliBalance!) / 1000);
  CurrencyCode get currencyCodeAsEnum {
    final codes = CurrencyCode.values.where((element) => currencyCode == element.name);
    if (codes.isEmpty) {
      return CurrencyCode.USD;
    }
    return codes.first;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['description'] = description ?? ""; //go-gin cannot bind with null so send empty string
    data['status'] = status;
    data['initial_balance'] = initialMilliBalance;
    data['currency_code'] = currencyCode;
    data['type'] = type;
    return data;
  }

  factory BillAccount.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    final name = json["name"];
    final description = json["description"];
    final status = json["status"];
    final milliBalance = json["balance"];
    final initialMilliBalance = json["initial_balance"];
    final currencyCode = json["currency_code"];
    final type = json["type"];
    return BillAccount(
        type: type,
        name: name,
        status: status,
        milliBalance: milliBalance,
        initialMilliBalance: initialMilliBalance,
        currencyCode: currencyCode,
        description: description,
        id: id,
        createdAt: createdAt);
  }
}
