import 'package:inventory_frontend/domain/stock.transaction/entities.dart';

class StockTransactionFilter {
  final StockMovement? stockMovement;
  StockTransactionFilter({this.stockMovement});
}
