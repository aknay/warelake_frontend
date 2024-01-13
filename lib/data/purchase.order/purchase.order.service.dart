import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/data/purchase.order/purchase.order.repository.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase.order.service.g.dart';

class PurchaseOrderService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final PurchaseOrderRepository _purchaseOrderRepo;
  PurchaseOrderService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required PurchaseOrderRepository purchaseOrderRepo})
      : _purchaseOrderRepo = purchaseOrderRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, Unit>> createPurchaseOrder(PurchaseOrder po) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError =
          await _purchaseOrderRepo.issuedPurchaseOrder(purchaseOrder: po, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, PurchaseOrder>> getPurchaseOrder({required String purchaseOrderId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError =
          await _purchaseOrderRepo.get(purchaseOrderId: purchaseOrderId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, List<PurchaseOrder>>> list() async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _purchaseOrderRepo.list(teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r.data));
    });
  }

  Future<Either<String, Unit>> converteToReceived({required String purchaseOrderId, required DateTime date}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _purchaseOrderRepo.receivedItems(
          purchaseOrderId: purchaseOrderId, date: date, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }
}

@Riverpod(keepAlive: true)
PurchaseOrderService purchaseOrderService(PurchaseOrderServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final purchaseOrderRepo = ref.watch(purchaseOrderRepositoryProvider);
  return PurchaseOrderService(
      authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, purchaseOrderRepo: purchaseOrderRepo);
}
