import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/monthly.order.summary/entities.dart';
import 'package:warelake/data/monthly.order.summary/monthly.order.summary.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.order.summary/api.dart';

part 'monthly.order.summary.service.g.dart';

class MonthlyOderSummaryService {
  MonthlyOderSummaryService({required this.api, required this.authService, required this.teamIdSharedRefRepository});

  final MonthlyOrderSummaryApi api;
  final AuthRepository authService;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;

  Future<Either<ErrorResponse, MonthlyOrderSummaryWithCurrency>> get() async {
    final token = await authService.shouldGetToken();

    final teamIdOrNone = teamIdSharedRefRepository.existingTeamId;
    if (teamIdOrNone.isNone()) {
      return Left(ErrorResponse.withOtherError(message: "Team Id is empty"));
    }
    final currencyCodeOrError = teamIdSharedRefRepository.currencyCode;
    if (currencyCodeOrError.isNone()) {
      return Left(ErrorResponse.withOtherError(message: "currency code is empty"));
    }
    final currencyCode = currencyCodeOrError.toIterable().first;

    final monthlySummaryOrError = await api.get(teamId: teamIdOrNone.toIterable().first, token: token);
    return monthlySummaryOrError.fold(
        (l) => left(l), (r) => right(MonthlyOrderSummaryWithCurrency.from(r, currencyCode)));
  }
}

@Riverpod(keepAlive: true)
MonthlyOderSummaryService monthlyOrderSummaryService(MonthlyOrderSummaryServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final monthlySummaryRepo = ref.watch(monthlyOrderSummaryRepositoryProvider);
  return MonthlyOderSummaryService(
    teamIdSharedRefRepository: teamIdSharedRefRepo,
    api: monthlySummaryRepo,
    authService: authRepo,
  );
}
