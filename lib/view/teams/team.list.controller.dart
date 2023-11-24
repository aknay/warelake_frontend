import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team.list.controller.g.dart';

@riverpod
class TeamListController extends _$TeamListController {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  // Future<bool> hasTeam() async {
  //     TeamRestApi().create(team: team, token: token)
  // }

  // Future<void> deleteEntry(EntryID entryId) async {
  //   final currentUser = ref.read(authRepositoryProvider).currentUser;
  //   if (currentUser == null) {
  //     throw AssertionError('User can\'t be null');
  //   }
  //   final repository = ref.read(entriesRepositoryProvider);
  //   state = const AsyncLoading();
  //   state = await AsyncValue.guard(
  //       () => repository.deleteEntry(uid: currentUser.uid, entryId: entryId));
  // }
}
