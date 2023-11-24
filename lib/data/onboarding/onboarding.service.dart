import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/onboarding.repository.dart';
import 'package:inventory_frontend/data/team/team.repository.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding.service.g.dart';

class OnboardingService {
  final AuthRepository authRepo;
  final OnboardingRepository onboardingRepository;
  final TeamRepository teamRepository;
  OnboardingService({required this.authRepo, required this.onboardingRepository, required this.teamRepository});

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
      final teamIdOrNone = onboardingRepository.hasTeamId;

      return await teamIdOrNone.fold(() async {
        if (teamList.length == 1) {
          onboardingRepository.setOnboardingComplete(teamId: teamList.first.id!);
        }
        return right(some(teamList));
      }, (existingTeamId) async {
        final isExistingTeamIdIsPartOfTeamList = teamList.where((element) => element.id! == existingTeamId).isNotEmpty;
        if (isExistingTeamIdIsPartOfTeamList) {
          final currentTeam = teamList.where((element) => element.id! == existingTeamId).first;
          return right(some([currentTeam]));
        } else {
          await onboardingRepository.clearTeamId();
          return right(some(teamList));
        }
      });
    }
  }
}

@Riverpod(keepAlive: true)
// @riverpod
OnboardingService onboardingService(OnboardingServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final onBoardingRepo = ref.watch(onboardingRepositoryProvider);
  final teamRepo = ref.watch(teamRepositoryProvider);
  return OnboardingService(authRepo: authRepo, onboardingRepository: onBoardingRepo, teamRepository: teamRepo);
}
