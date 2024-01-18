import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/stock/transactions/entities.dart';

final stockTransctionFilterProvider = StateProvider<StockTransactionFilter>(
  (ref) => StockTransactionFilter(),
);
