import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding.repository.g.dart';

class OnboardingRepository {
  OnboardingRepository(this.sharedPreferences);
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

  // bool isOnboardingComplete() => sharedPreferences.getBool(onboardingCompleteKey) ?? false;
}

@Riverpod(keepAlive: true)
// @riverpod
OnboardingRepository onboardingRepository(OnboardingRepositoryRef ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return OnboardingRepository(preferences);
}
