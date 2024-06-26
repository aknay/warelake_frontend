import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/view/common.widgets/dialogs/yes.no.dialog.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/settings/team/app.version.text.dart';
import 'package:warelake/view/settings/team/team.flashcards.dart';
import 'package:warelake/view/settings/team/user.flashcards.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,

      ),
      body: Center(
        child: Column(
      
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // SizedBox(height: 80,child: Container(color: Theme.of(context).colorScheme.secondaryContainer),),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              child: Text(
                'User',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // gapH8,
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: UserFlashcards(),
            ),
            gapH16,
             const Divider(),
            gapH16,
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Team',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const TeamFlashCard(),
            const Spacer(),
            const SizedBox(height: 8),
            const Center(child: AppVersionText()),
            const Divider(),
            TextButton.icon(
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
              label: const Text('Logout'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
