import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/user/current.user.provider.dart';

class UserInfoWidget extends ConsumerWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return switch (currentUser) {
      AsyncError(:final error) => Text('Error: $error'),
      AsyncData(:final value) => Text(value.email),
      _ => const CircularProgressIndicator(),
    };
  }
}
