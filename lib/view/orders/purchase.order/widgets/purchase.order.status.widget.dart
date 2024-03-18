import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class PurchaseOrderStausWidget extends ConsumerWidget {
  final PurchaseOrderStatus status;
  const PurchaseOrderStausWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
