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


// @riverpod
// class AsyncTeamRepository extends _$AsyncTeamRepository {
//   Future<List<Team>> _fetchTodo() async {
// TeamRestApi().


//     // final json = await http.get('api/todos');
//     // final todos = jsonDecode(json) as List<Map<String, dynamic>>;
//     // return todos.map(Todo.fromJson).toList();
//   }

//   @override
//   FutureOr<List<Todo>> build() async {
//     // Load initial todo list from the remote repository
//     return _fetchTodo();
//   }