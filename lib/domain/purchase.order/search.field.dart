import 'package:warelake/domain/entities.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';

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
    if (startingAfterPurchaseOrderId != null) {
      additionalQuery['starting_after'] = startingAfterPurchaseOrderId!;
    }
    if (status != null) {
      additionalQuery['status'] = status!.name;
    }
    if (itemVariationName != null) {
      additionalQuery['item_variation_name'] = itemVariationName!;
    }
    if (dateRange != null) {
      additionalQuery['date_range'] = dateRange!.toMap();
    }

    return additionalQuery;
  }
}
