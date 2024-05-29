import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/team/api.dart';
import 'package:warelake/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'team.service.g.dart';

class TeamService {
  final AuthRepository authRepo;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;
  final TeamApi teamRepository;
  TeamService({required this.authRepo, required this.teamIdSharedRefRepository, required this.teamRepository});

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<Either<ErrorResponse, bool>> get isOnboardingCompleted async {
    final token = await authRepo.shouldGetToken();
    log("print call?");
    final onlineTeamListOrError = await teamRepository.list(token: token);

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
    final newTeamOrError = await teamRepository.create(team: team, token: token);
    await newTeamOrError.fold((l) => null, (r) async {
      await teamIdSharedRefRepository.setTeam(team: r);
    });

    return newTeamOrError;
  }

  Future<Either<String, Team>> getTeam() async {
    final teamIdOrNone = teamIdSharedRefRepository.existingTeamId;

    if (teamIdOrNone.isNone()) {
      return left("team id is not available");
    }
    final teamId = teamIdOrNone.toNullable()!;

    // final team = teamRepository.teamApi.
    final token = await authRepo.shouldGetToken();
    final newTeamOrError = await teamRepository.get(teamId: teamId, token: token);
    await newTeamOrError.fold((l) => null, (r) async {
      await teamIdSharedRefRepository.setTeam(team: r);
    });
  
    return newTeamOrError.fold((l) => left(l.message), (r) => right(r));
  }
}

@Riverpod(keepAlive: true)
// @riverpod
TeamService teamService(TeamServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final teamRepo = ref.watch(teamRepositoryProvider);
  return TeamService(authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, teamRepository: teamRepo);
}
