import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/data/sale.order/sale.order.repository.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _saleOrderRepo.issuedSaleOrder(saleOrder: saleOrder, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, List<SaleOrder>>> list() async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _saleOrderRepo.listSaleOrder(teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r.data));
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
