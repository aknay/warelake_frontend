import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/team/team.repository.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;
part 'team.list.controller.g.dart';

@riverpod
class TeamListController extends _$TeamListController {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<bool> submit({required String teamName, required tz.Location location, required Currency currency}) async {
    final team = Team.create(name: teamName, timeZone: location.name, currencyCode: currency.toCurrencyCode);
    final token = await ref.read(authRepositoryProvider).shouldGetToken();
    // if (currentUser.isNone()) {
    //   throw AssertionError('User can\'t be null');
    // }
    final createdOrError = await ref.read(teamRepositoryProvider).teamApi.create(team: team, token: token);

    return createdOrError.fold((l) {
      state = AsyncError("Unable to create a team", StackTrace.current);
      return false;
    }, (r) => true);
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
