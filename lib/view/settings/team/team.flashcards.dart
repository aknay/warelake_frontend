import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/settings/team/fetch.team.controller.dart';

class TeamFlashCard extends ConsumerWidget {
  const TeamFlashCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTeam = ref.watch(fetchTeamControllerProvider);
    return asyncTeam.when(
        data: (data) {
          final planType =
              data.planType == 1212 ? "Personal Plan" : "Unknown Plan";

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text("Team Name:"),
                  trailing: Text(data.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                ListTile(
                  title: const Text("Current Plan:"),
                  trailing: Text(planType,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ]);
        },
        error: (Object error, StackTrace stackTrace) =>
            const Center(child: Text("Having error")),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
