import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/main/user/current.user.provider.dart';

class UserFlashcards extends ConsumerWidget {
  const UserFlashcards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.name),
            Text(data.email),
            Text(data.isTeamOwner == true ? 'Owner' : 'User'),
          ],
        ),
        error: (object, error) => Text('Error: $error'),
        loading: () => const CircularProgressIndicator());
  }
}
