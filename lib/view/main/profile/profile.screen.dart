import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),

            // Text( "version: ${ref.watch(appVersionProvider)}"),
            const SizedBox(height: 8),
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_sharp),
              onPressed: () async {
                final toSignOutOrNull = await showDialog<bool?>(
                  context: context,
                  builder: (BuildContext context) {
                    return const YesOrNoDialog(
                      actionWord: "Sign Out",
                      title: "Sure?",
                      content: "Are you sure you want to sign out?",
                    );
                  },
                );

                if (toSignOutOrNull != null && toSignOutOrNull) {
                  await ref.read(authRepositoryProvider).signOut();
                }
              },
              label: Text('Logout', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.green)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
