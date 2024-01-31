import 'package:inventory_frontend/domain/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';



class SaleOrderSearchField {
  final String? startingAfterSaleOrderId;
  final SaleOrderStatus? status;
  final DateRange? dateRange;
  final String? itemVariationName;
  SaleOrderSearchField({
    this.startingAfterSaleOrderId,
    this.status,
    this.dateRange,
    this.itemVariationName,
  });
}
