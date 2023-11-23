import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/team/api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team.repository.g.dart';

class TeamRepository {
  final TeamApi teamApi;
  TeamRepository({required this.teamApi});
}

@Riverpod(keepAlive: true)
TeamRepository teamRepository(TeamRepositoryRef ref) {
  final api = TeamRestApi();
  return TeamRepository(teamApi: api);
}
