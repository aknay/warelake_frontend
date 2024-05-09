import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/main/widgets/add.item.group.widget.dart';
import 'package:warelake/view/main/widgets/item.utilization.wiget.dart';
import 'package:warelake/view/main/widgets/low.stock.check.widget/low.stock.check.widget.dart';
import 'package:warelake/view/main/widgets/po.so.widget.dart';
import 'package:warelake/view/main/widgets/stock.in.out.widget.dart';
import 'package:warelake/view/monthly.order.summary/monthly.order.summary.widget.dart';
import 'package:warelake/view/routing/app.router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warelake"),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(AppRoute.profile.name);
              },
              icon: const Icon(Icons.account_circle_outlined)),
        ],
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ItemUtilizationWidget(),
              gapH8,
              MonthlyOrderSummaryWdiget(),
              gapH8,
              AddItemGroupWidget(),
              gapH8,
              StockInOutWidget(),
              gapH8,
              LowStockCheckWidget(),
              gapH8,
              PoSoWidget(),
            ],
          ),
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
