import 'package:dartz/dartz.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:warelake/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'team.id.shared.ref.repository.g.dart';

class TeamIdSharedRefereceRepository {
  TeamIdSharedRefereceRepository(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';
  static const teamCurrencyKey = 'team_currency_key';

  Future<void> setTeam({required Team team}) async {
    await _sharedPreferences.setString(onboardingCompleteKey, team.id!);
    await _sharedPreferences.setString(teamCurrencyKey, team.currencyCode.name);
  }

  Option<String> get existingTeamId {
    final teamIdOrNone = _sharedPreferences.getString(onboardingCompleteKey);
    return optionOf(teamIdOrNone);
  }

  Option<CurrencyCode> get currencyCode {
    final currencyCodeOrNone = _sharedPreferences.getString(teamCurrencyKey);
    return optionOf(currencyCodeOrNone).fold(() => const None(), (x) => Some(CurrencyCode.values.byName(x)));
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
