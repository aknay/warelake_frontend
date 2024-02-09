import 'package:warelake/domain/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';

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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> additionalQuery = {};
    if (startingAfterSaleOrderId != null) {
      additionalQuery['starting_after'] = startingAfterSaleOrderId;
    }
    if (status != null) {
      additionalQuery['status'] = status?.name;
    }
    if (itemVariationName != null) {
      additionalQuery['item_variation_name'] = itemVariationName;
    }
    if (dateRange != null) {
      additionalQuery['date_range'] = dateRange?.toMap();
    }

    return additionalQuery;
  }
}
