import 'package:dartz/dartz.dart';

class ExpiryDateOrDisable {
  Option<DateTime> expiryDate;
  bool disableExpiryDate;

  ExpiryDateOrDisable({this.expiryDate = const None(), this.disableExpiryDate = false});

  factory ExpiryDateOrDisable.disableExpiryDate() {
    return ExpiryDateOrDisable(expiryDate: const None(), disableExpiryDate: true);
  }

  factory ExpiryDateOrDisable.updateExpiryDate(DateTime dateTime) {
    return ExpiryDateOrDisable(expiryDate: Some(dateTime), disableExpiryDate: false);
  }

  Map<String, dynamic> toMap() {
    return {
      'expiry_date_or_null': expiryDate.fold(() => null, (a) => a.toUtc().toIso8601String()),
      'disable_expiry_date': disableExpiryDate
    };
  }
}


class ItemVariationPayload {
  Option<String> name;
  Option<double> pruchasePrice;
  Option<double> salePrice;
  Option<String> barcode;
  Option<int> minimumStockOrNone;

  Option<ExpiryDateOrDisable> expiryDateOrDisable;

  ItemVariationPayload({
    this.name = const None(),
    this.pruchasePrice =  const None(),
    this.salePrice = const None(),
    this.barcode = const None(),
    this.minimumStockOrNone = const None(),
    this.expiryDateOrDisable = const None(),
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name.fold(() => null, (x) => x),
      'purchase_price': pruchasePrice.fold(() => null, (x) => (x * 1000).toInt()),
      'sale_price': salePrice.fold(() => null, (x) => (x * 1000).toInt()),
      'barcode': barcode.fold(() => null, (x) => x),
      'minimum_stock_count': minimumStockOrNone.fold(() => null, (a) => a),
      'expiry_date_or_disable': expiryDateOrDisable.fold(() => null, (a) => a.toMap())
    };
  }
}