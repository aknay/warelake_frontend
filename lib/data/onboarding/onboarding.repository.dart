import 'package:inventory_frontend/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding.repository.g.dart';

class OnboardingRepository {
  OnboardingRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  bool isOnboardingComplete() =>
      sharedPreferences.getBool(onboardingCompleteKey) ?? false;
}

// @Riverpod(keepAlive: true)
// Future<OnboardingRepository> onboardingRepository(
//     OnboardingRepositoryRef ref) async {
//   return OnboardingRepository(await SharedPreferences.getInstance());
// }

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(
    OnboardingRepositoryRef ref)  {
  final preferences = ref.watch(sharedPreferencesProvider);
  return OnboardingRepository(preferences);
}