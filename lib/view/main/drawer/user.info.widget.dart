import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/user/current.user.provider.dart';

class UserInfoWidget extends ConsumerWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
        data: (data) => Text(data.email),
        error: (object, error) => Text('Error: $error'),
        loading: () => const CircularProgressIndicator());
  }
}
