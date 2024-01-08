import 'package:inventory_frontend/domain/stock.transaction/entities.dart';

class StockTransactionSearchField {
  final String? startingAfterStockTransactionId;
  final StockMovement? stockMovement;
  final String? itemVaraiationName;
  StockTransactionSearchField({
    this.startingAfterStockTransactionId,
    this.stockMovement,
    this.itemVaraiationName,
  });
}
