import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.service.g.dart';

class ItemService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final ItemRepository _itemRepo;
  ItemService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required ItemRepository itemRepo})
      : _itemRepo = itemRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, Unit>> createItem(Item item) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _itemRepo.createItem(item: item, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, Item>> getItem({required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _itemRepo.getItem(itemId: itemId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, List<Item>>> list() async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.getItemList(teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r.data));
    });
  }

  Future<Either<String, Unit>> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
  }) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.updateItemVariation(
          payload: payload, itemId: itemId, itemVariationId: itemVariationId, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, Unit>> updateItem({required ItemUpdatePayload payload, required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.getTemId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"), (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.updateItem(payload: payload, itemId: itemId, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }
}

@Riverpod(keepAlive: true)
ItemService itemService(ItemServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final itemRepo = ref.watch(itemRepositoryProvider);
  return ItemService(authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, itemRepo: itemRepo);
}
