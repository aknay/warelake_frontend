import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/routing/app.router.dart';

class LowStockCheckWidget extends ConsumerWidget {
  const LowStockCheckWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Low Stock Check', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.av_timer),
              title: const Text('Stock Shortage'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                context.goNamed(AppRoute.lowStockIteamVariations.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
