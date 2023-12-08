import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'team.id.shared.ref.repository.g.dart';

class TeamIdSharedRefereceRepository {
  TeamIdSharedRefereceRepository(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<void> setOnboardingComplete({required String teamId}) async {
    await _sharedPreferences.setString(onboardingCompleteKey, teamId);
  }

  Option<String> get getTemId {
    final teamIdOrNone = _sharedPreferences.getString(onboardingCompleteKey);
    return optionOf(teamIdOrNone);
  }

  Future<void> clearTeamId() async {
    await _sharedPreferences.setString(onboardingCompleteKey, '');
  }
}

@Riverpod(keepAlive: true)
TeamIdSharedRefereceRepository teamIdSharedReferenceRepository(TeamIdSharedReferenceRepositoryRef ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return TeamIdSharedRefereceRepository(preferences);
}
