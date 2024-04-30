import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class PurchaseOrderStausWidget extends StatelessWidget {
  final Option<PurchaseOrderStatus> statusOrNone;
  const PurchaseOrderStausWidget(this.statusOrNone, {super.key});

  @override
  Widget build(BuildContext context) {
    if (statusOrNone.isNone()){
             return const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey),
            gapW4,
            Text('Unknown'),
          ],
        );
    }
    final status = statusOrNone.toIterable().first;
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
