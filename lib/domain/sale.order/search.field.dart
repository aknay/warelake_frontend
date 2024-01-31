import 'package:inventory_frontend/domain/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';

class SaleOrderSearchField {
  final String? startingAfterPurchaseOrderId;
  final SaleOrderStatus? status;
  final DateRange? dateRange;
  final String? itemVariationName;
  SaleOrderSearchField({
    this.startingAfterPurchaseOrderId,
    this.status,
    this.dateRange,
    this.itemVariationName,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> additionalQuery = {};
    additionalQuery['starting_after'] = startingAfterPurchaseOrderId;
    additionalQuery['status'] = status?.name;
    additionalQuery['item_variation_name'] = itemVariationName;
    additionalQuery['date_range'] = dateRange?.toMap();
    return additionalQuery;
  }
}
