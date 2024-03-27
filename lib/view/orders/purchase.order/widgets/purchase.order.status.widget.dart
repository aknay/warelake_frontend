import 'package:flutter/material.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class PurchaseOrderStausWidget extends StatelessWidget {
  final PurchaseOrderStatus status;
  const PurchaseOrderStausWidget(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PurchaseOrderStatus.issued:
        return const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey),
            gapW4,
            Text('Issued'),
          ],
        );
      case PurchaseOrderStatus.received:
        return const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
            ),
            gapW4,
            Text('Received')
          ],
        );
    }
  }
}
