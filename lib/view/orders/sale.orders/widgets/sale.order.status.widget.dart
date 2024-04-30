import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class SaleOrderStausWidget extends StatelessWidget {
  final Option<SaleOrderStatus> statusOrNone;
  const SaleOrderStausWidget({super.key, required this.statusOrNone});

  @override
  Widget build(BuildContext context) {
    if (statusOrNone.isNone()) {
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
