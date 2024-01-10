import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/data/team/team.repository.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'onboarding.service.g.dart';

class OnboardingService {
  final AuthRepository authRepo;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;
  final TeamRepository teamRepository;
  OnboardingService({required this.authRepo, required this.teamIdSharedRefRepository, required this.teamRepository});

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<Either<ErrorResponse, Option<List<Team>>>> get isOnboardingCompleted async {
    final token = await authRepo.shouldGetToken();
    log("print call?");
    final teamListOrError = await teamRepository.teamApi.list(token: token);

    if (teamListOrError.isLeft()) {
      return left(ErrorResponse.withOtherError(message: "unable to connect"));
    }

    final teamList = teamListOrError.toIterable().first.data;

    if (teamList.isEmpty) {
      return right(none());
    } else {
      final teamIdOrNone = teamIdSharedRefRepository.getTemId;

      return await teamIdOrNone.fold(() async {
        if (teamList.length == 1) {
          teamIdSharedRefRepository.setOnboardingComplete(team: teamList.first);
        }
        return right(some(teamList));
      }, (existingTeamId) async {
        final isExistingTeamIdIsPartOfTeamList = teamList.where((element) => element.id! == existingTeamId).isNotEmpty;
        if (isExistingTeamIdIsPartOfTeamList) {
          final currentTeam = teamList.where((element) => element.id! == existingTeamId).first;
          return right(some([currentTeam]));
        } else {
          await teamIdSharedRefRepository.clearTeamId();
          return right(some(teamList));
        }
      });
    }
  }

  Future<Either<ErrorResponse, Team>> submit(
      {required String teamName, required tz.Location location, required Currency currency}) async {
    final team = Team.create(name: teamName, timeZone: location.name, currencyCode: currency.toCurrencyCode);
    final token = await authRepo.shouldGetToken();
    final newTeamOrError = await teamRepository.teamApi.create(team: team, token: token);
    await newTeamOrError.fold((l) => null, (r) async {
      await teamIdSharedRefRepository.setOnboardingComplete(team: r);
    });

    return newTeamOrError;
  }
}

@Riverpod(keepAlive: true)
// @riverpod
OnboardingService onboardingService(OnboardingServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final teamRepo = ref.watch(teamRepositoryProvider);
  return OnboardingService(
      authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, teamRepository: teamRepo);
}
