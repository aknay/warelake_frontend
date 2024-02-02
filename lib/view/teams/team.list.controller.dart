import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/onboarding/team.service.dart';
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
    final addedOrError =
        await ref.read(teamServiceProvider).submit(teamName: teamName, location: location, currency: currency);
    return addedOrError.fold((l) {
      state = AsyncError("Unable to create a team", StackTrace.current);
      return false;
    }, (r) => true);
  }
}
