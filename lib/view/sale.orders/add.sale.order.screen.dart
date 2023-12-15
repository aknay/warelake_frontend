import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class AddSaleOrderScreen extends ConsumerStatefulWidget {
  const AddSaleOrderScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddSaleOrderScreenState();
}

class _AddSaleOrderScreenState extends ConsumerState<AddSaleOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Add Sale Order")), body: Column(children: [
      TextButton(onPressed: () { 
              context.goNamed(
                AppRoute.addLineItem.name,
              );
       },
      child: Text("Add Line Item"),)],),);
  }
}
