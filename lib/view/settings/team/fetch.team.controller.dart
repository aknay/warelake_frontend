import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/onboarding/team.service.dart';
import 'package:warelake/domain/team/entities.dart';

part 'fetch.team.controller.g.dart';

@riverpod
Future<Team> fetchTeamController(FetchTeamControllerRef ref) async {
  final teamOrError = await ref.read(teamServiceProvider).getTeam();
  if (teamOrError.isRight()) {
    return teamOrError.toIterable().first;
  }
  throw Exception('unable to get a team');
}
