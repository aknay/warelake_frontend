import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/view/routing/app.router.dart';

class ExpiringStockCheckWidget extends ConsumerWidget {
  const ExpiringStockCheckWidget({super.key});

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
              child: Text('Expiry Check', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_bottom),
              title: const Text('Expiring Items'),
              trailing: const FaIcon(FontAwesomeIcons.angleRight),
              onTap: () {
                context.goNamed(AppRoute.checkExpiringStockIteamVariations.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
