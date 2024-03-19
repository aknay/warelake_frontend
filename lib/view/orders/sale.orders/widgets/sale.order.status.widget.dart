import 'package:flutter/material.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class SaleOrderStausWidget extends StatelessWidget {
  final SaleOrderStatus status;
  const SaleOrderStausWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SaleOrderStatus.issued:
        return const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey),
            gapW4,
            Text('Issued'),
          ],
        );
      case SaleOrderStatus.delivered:
        return const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
            ),
            gapW4,
            Text('Delivered'),
          ],
        );
    }
  }
}
