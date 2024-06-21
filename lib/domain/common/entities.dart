import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/valueobject.dart';

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