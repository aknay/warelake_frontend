import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchItemByNameProvider = StateProvider<Option<String>>(
  (ref) => const None(),
);

class ItemSearchWidget extends ConsumerWidget {
  const ItemSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      initialValue: ref.watch(searchItemByNameProvider).toNullable(),
      onChanged: (value) async {
        if (value.isEmpty) {
          ref.read(searchItemByNameProvider.notifier).state = const None();
        } else if (value.length > 2) {
          ref.read(searchItemByNameProvider.notifier).state = Some(value);
        }
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        hintText: "Search item group name",
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
