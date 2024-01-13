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

  Future<Either<ErrorResponse, bool>> get isOnboardingCompleted async {
    final token = await authRepo.shouldGetToken();
    log("print call?");
    final onlineTeamListOrError = await teamRepository.teamApi.list(token: token);

    if (onlineTeamListOrError.isLeft()) {
      return left(ErrorResponse.withOtherError(message: "unable to connect"));
    }

    final onlineTeamList = onlineTeamListOrError.toIterable().first.data;

    if (onlineTeamList.isEmpty) {
      return right(false);
    } else if (onlineTeamList.length == 1) {
      final onlineTeam = onlineTeamList.first;
      final exitingTeamIdOrNone = teamIdSharedRefRepository.existingTeamId;

      return exitingTeamIdOrNone.fold(() async {
        await teamIdSharedRefRepository.setTeam(team: onlineTeam);
        return right(true);
      }, (existingTeamId) {
        if (existingTeamId == onlineTeam.id) {
          return right(true);
        } else {
          teamIdSharedRefRepository.setTeam(team: onlineTeam);
          return right(true);
        }
      });
    } else {
      //TODO we dont know how to handle with multiple team
    }
    //should not reach here
    return right(false);
  }

  Future<Either<ErrorResponse, Team>> submit(
      {required String teamName, required tz.Location location, required Currency currency}) async {
    final team = Team.create(name: teamName, timeZone: location.name, currencyCode: currency.toCurrencyCode);
    final token = await authRepo.shouldGetToken();
    final newTeamOrError = await teamRepository.teamApi.create(team: team, token: token);
    await newTeamOrError.fold((l) => null, (r) async {
      await teamIdSharedRefRepository.setTeam(team: r);
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
