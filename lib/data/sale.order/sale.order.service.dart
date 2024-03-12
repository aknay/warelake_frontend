import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/sale.order/search.field.dart';

part 'sale.order.service.g.dart';

class SaleOrderService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final SaleOrderRepository _saleOrderRepo;
  SaleOrderService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required SaleOrderRepository saleOrderRepo})
      : _saleOrderRepo = saleOrderRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, Unit>> createSaleOrder(SaleOrder saleOrder) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _saleOrderRepo.create(saleOrder: saleOrder, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, SaleOrder>> getSaleOrder({required String saleOrderId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _saleOrderRepo.get(saleOrderId: saleOrderId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, ListResponse<SaleOrder>>> list({String? lastSaleOrderId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final searchField = SaleOrderSearchField(startingAfterSaleOrderId: lastSaleOrderId);

      final items = await _saleOrderRepo.list(teamId: teamId, token: token, searchField: searchField);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, Unit>> converteToDelivered({required String saleOrderId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _saleOrderRepo.setToDelivered(
          saleOrderId: saleOrderId, date: DateTime.now(), teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, Unit>> delete({required SaleOrder saleOrder}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _saleOrderRepo.delete(saleOrderId: saleOrder.id!, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }
}

@Riverpod(keepAlive: true)
SaleOrderService saleOrderService(SaleOrderServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final saleOrderRepo = ref.watch(saleOrderRepositoryProvider);
  return SaleOrderService(
      authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, saleOrderRepo: saleOrderRepo);
}
