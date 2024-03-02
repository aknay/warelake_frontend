import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/main/drawer/drawer.dart';
import 'package:warelake/view/main/item.utilization.wiget.dart';
import 'package:warelake/view/main/widgets/add.item.group.widget.dart';
import 'package:warelake/view/routing/app.router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(AppRoute.profile.name);
              },
              icon: const Icon(Icons.account_circle_outlined)),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            ItemUtilizationWidget(),
            gapH16,
            AddItemGroupWidget()
          ],
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }
}
