import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/view/common.widgets/text.label.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/constants/colors.dart';

class PurchaseOrderStausWidget extends StatelessWidget {
  final Option<PurchaseOrderStatus> statusOrNone;
  const PurchaseOrderStausWidget(this.statusOrNone, {super.key});

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
      case PurchaseOrderStatus.issued:
        return const TextLabel(text: 'Issued', color: rallyYellow);

      case PurchaseOrderStatus.received:
        return const TextLabel(text: 'Received', color: rallyGreen);
    }
  }
}
