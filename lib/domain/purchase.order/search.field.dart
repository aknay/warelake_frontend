import 'package:inventory_frontend/domain/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/valueobject.dart';

class PurchaseOrderSearchField {
  final String? startingAfterPurchaseOrderId;
  final PurchaseOrderStatus? status;
  final DateRange? dateRange;
  final String? itemVariationName;
  PurchaseOrderSearchField({
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
