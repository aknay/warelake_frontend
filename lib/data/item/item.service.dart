import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

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

  Future<Either<String, Unit>> createItemRequest(CreateItemRequest item) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError = await _itemRepo.createItemRequest(
          request: item, teamId: teamId, token: token);
      return createdOrError.fold(
          (l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, Item>> getItem({required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError =
          await _itemRepo.getItem(itemId: itemId, teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  // Future<Either<String, List<ItemVariation>>> getItemVariations(
  //     {required String itemId}) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final createdOrError = await _itemRepo.getItemVariations(
  //         itemId: itemId, teamId: teamId, token: token);
  //     return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
  //   });
  // }

  // Future<Either<String, ItemVariation>> getItemVariation(
  //     {required String itemId, required String itemVariationId}) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final createdOrError = await _itemRepo.getItemVariation(
  //         itemId: itemId,
  //         itemVariationId: itemVariationId,
  //         teamId: teamId,
  //         token: token);
  //     return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
  //   });
  // }

  Future<Either<String, ListResponse<Item>>> list(
      {ItemSearchField? itemSearchField}) async {
    log("call in service?");
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.getItemList(
          teamId: teamId, token: token, itemSearchField: itemSearchField);
      return items.fold((l) => Left(l.message), (r) => Right(r));
    });
  }

  // Future<Either<String, ListResponse<ItemVariation>>> listItemVaration(
  //     {ItemVariationSearchField? itemSearchField}) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final items = await _itemRepo.getItemVariationList(
  //         teamId: teamId, token: token, searchField: itemSearchField);
  //     return items.fold((l) => Left(l.message), (r) => Right(r));
  //   });
  // }

  // Future<Either<String, ListResponse<ItemVariation>>>
  //     getLowStockItemVarations() async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final items = await _itemRepo.getLowLevelItemVariationList(
  //         teamId: teamId, token: token);
  //     return items.fold((l) => Left(l.message), (r) => Right(r));
  //   });
  // }

  // Future<Either<String, Unit>> updateItemVariation({
  //   required ItemVariationPayload payload,
  //   required String itemId,
  //   required String itemVariationId,
  // }) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final items = await _itemRepo.updateItemVariation(
  //         payload: payload,
  //         itemId: itemId,
  //         itemVariationId: itemVariationId,
  //         teamId: teamId,
  //         token: token);
  //     return items.fold((l) => Left(l.message), (r) => const Right(unit));
  //   });
  // }

  // Future<Either<String, Unit>> deleteItemVariation({
  //   required String itemId,
  //   required String itemVariationId,
  // }) async {
  //   final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
  //   return teamIdOrNone.fold(() => const Left("Team Id is empty"),
  //       (teamId) async {
  //     final token = await _authRepo.shouldGetToken();
  //     final items = await _itemRepo.deleteItemVariation(
  //         itemId: itemId,
  //         itemVariationId: itemVariationId,
  //         teamId: teamId,
  //         token: token);
  //     return items.fold((l) => Left(l.message), (r) => const Right(unit));
  //   });
  // }

  Future<Either<String, Unit>> deleteItem({required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.deleteItem(
          itemId: itemId, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, Unit>> updateItem(
      {required ItemUpdatePayload payload, required String itemId}) async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final items = await _itemRepo.updateItem(
          payload: payload, itemId: itemId, teamId: teamId, token: token);
      return items.fold((l) => Left(l.message), (r) => const Right(unit));
    });
  }

  Future<Either<String, ItemUtilization>> get itemUtilization async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    return teamIdOrNone.fold(() => const Left("Team Id is empty"),
        (teamId) async {
      final token = await _authRepo.shouldGetToken();
      final createdOrError =
          await _itemRepo.getItemUtilization(teamId: teamId, token: token);
      return createdOrError.fold((l) => Left(l.message), (r) => Right(r));
    });
  }
}

@Riverpod(keepAlive: true)
ItemService itemService(ItemServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo =
      ref.watch(teamIdSharedReferenceRepositoryProvider);
  final itemRepo = ref.watch(itemRepositoryProvider);
  return ItemService(
      authRepo: authRepo,
      teamIdSharedRefRepository: teamIdSharedRefRepo,
      itemRepo: itemRepo);
}
