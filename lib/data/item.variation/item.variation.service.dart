import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/item.variation/item.variation.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

part 'item.variation.service.g.dart';

class ItemVariationService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final ItemVariationRepository _itemRepo;
  ItemVariationService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required ItemVariationRepository itemVariationRepo})
      : _itemRepo = itemVariationRepo,
        _teamIdSharedRefRepository = teamIdSharedRefRepository,
        _authRepo = authRepo;

  Future<Either<String, List<ItemVariation>>> getItemVariations(
      {required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _itemRepo.getItemVariations(
          itemId: itemId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, ItemVariation>> getItemVariation(
      {required String itemId, required String itemVariationId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _itemRepo.getItemVariation(
          itemId: itemId,
          itemVariationId: itemVariationId,
          teamId: teamId,
          token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, ListResponse<ItemVariation>>> listItemVaration(
      {ItemVariationSearchField? itemSearchField}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.getItemVariationList(
          teamId: teamId, token: token, searchField: itemSearchField);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, ListResponse<ItemVariation>>>
      getLowStockItemVarations() async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.getLowLevelItemVariationList(
          teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  Future<Either<String, Unit>> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
  }) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.updateItemVariation(
          payload: payload,
          itemId: itemId,
          itemVariationId: itemVariationId,
          teamId: teamId,
          token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, Unit>> deleteItemVariation({
    required String itemId,
    required String itemVariationId,
  }) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.deleteItemVariation(
          itemId: itemId,
          itemVariationId: itemVariationId,
          teamId: teamId,
          token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }
}

@Riverpod(keepAlive: true)
ItemVariationService itemVariationService(ItemVariationServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo =
      ref.watch(teamIdSharedReferenceRepositoryProvider);
  final itemVariationRepo = ref.watch(itemVariationRepositoryProvider);
  return ItemVariationService(
      authRepo: authRepo,
      teamIdSharedRefRepository: teamIdSharedRefRepo,
      itemVariationRepo: itemVariationRepo);
}
