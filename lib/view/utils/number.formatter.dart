import 'package:intl/intl.dart';
import 'package:warelake/data/currency.code/valueobject.dart';

class NumberFormatterUtils {
  static String currencyFormat({required double value, required CurrencyCode currencyCode}) {
    final isZeroDecimalCurrency =
        ZeroDecimalCurrency.values.where((element) => element.name == currencyCode.name).isNotEmpty;

    if (isZeroDecimalCurrency) {
      return NumberFormat.currency(locale: "ja_JP", symbol: '\$').format(value);
    }

    return NumberFormat.currency(locale: "en_US", symbol: '\$').format(value);
  }

  static String currencyFormatWithoutSymbol({required double value, required CurrencyCode currencyCode}) {
    final isZeroDecimalCurrency =
        ZeroDecimalCurrency.values.where((element) => element.name == currencyCode.name).isNotEmpty;

    if (isZeroDecimalCurrency) {
      return NumberFormat.currency(locale: "ja_JP", symbol: '').format(value);
    }
    return NumberFormat.currency(locale: "en_US", symbol: '').format(value);
  }

  static NumberFormat getFormatterWithoutSymbol({required CurrencyCode currencyCode}) {
    final isZeroDecimalCurrency =
        ZeroDecimalCurrency.values.where((element) => element.name == currencyCode.name).isNotEmpty;

    if (isZeroDecimalCurrency) {
      return NumberFormat.currency(locale: "ja_JP", symbol: '');
    }
    return NumberFormat.currency(locale: "en_US", symbol: '');
  }

  static String formatPercentage({required double value}) {
    final patern = NumberFormat.percentPattern();
    return patern.format(value);
  }
}
