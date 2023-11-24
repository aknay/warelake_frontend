import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'team.id.shared.ref.repository.g.dart';

class TeamIdSharedRefereceRepository {
  TeamIdSharedRefereceRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<void> setOnboardingComplete({required String teamId}) async {
    await sharedPreferences.setString(onboardingCompleteKey, teamId);
  }

  Option<String> get hasTeamId {
    final teamIdOrNone = sharedPreferences.getString(onboardingCompleteKey);
    return optionOf(teamIdOrNone);
  }

  Future<void> clearTeamId() async {
    await sharedPreferences.setString(onboardingCompleteKey, '');
  }
}

@Riverpod(keepAlive: true)
TeamIdSharedRefereceRepository teamIdSharedReferenceRepository(TeamIdSharedReferenceRepositoryRef ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return TeamIdSharedRefereceRepository(preferences);
}
