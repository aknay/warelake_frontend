import 'package:dartz/dartz.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/monthly.summary/monthly.summary.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.summary/api.dart';
import 'package:warelake/domain/monthly.summary/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monthly.summary.service.g.dart';

class MonthlySummaryService {
  MonthlySummaryService({required this.api, required this.authService, required this.teamIdSharedRefRepository});

  final MonthlySummaryApi api;
  final AuthRepository authService;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;

  Future<Either<ErrorResponse, List<MonthlySummary>>> get({required BillAccountId billAccountId}) async {
    final token = await authService.shouldGetToken();

    final teamIdOrNone = teamIdSharedRefRepository.existingTeamId;
    if (teamIdOrNone.isNone()) {
      return Left(ErrorResponse.withOtherError(message: "Team Id is empty"));
    }
    return await api.list(teamId: teamIdOrNone.toIterable().first, token: token, billAccountId: billAccountId);
  }
}

@Riverpod(keepAlive: true)
MonthlySummaryService monthlySummaryService(MonthlySummaryServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final monthlySummaryRepo = ref.watch(monthlySummaryRepositoryProvider);
  return MonthlySummaryService(
    teamIdSharedRefRepository: teamIdSharedRefRepo,
    api: monthlySummaryRepo,
    authService: authRepo,
  );
}
