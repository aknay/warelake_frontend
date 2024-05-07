import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

abstract class ItemApi {
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({
    required String teamId,
    required String token,
    ItemSearchField? itemSearchField,
  });

  Future<Either<ErrorResponse, ListResponse<ItemVariation>>> getItemVariationList({
    required String teamId,
    required String token,
    ItemVariationSearchField? searchField,
  });

  Future<Either<ErrorResponse, ListResponse<ItemVariation>>> getItemVariationListByItemId({
    required String teamId,
    required String itemId,
    required String token,
  });

  Future<Either<ErrorResponse, ListResponse<ItemVariation>>> getLowLevelItemVariationList({
    required String teamId,
    required String token,
    Option<String> startingAfterId = const None(),
  });

  Future<Either<ErrorResponse, Item>> createItemRequest({
    required CreateItemRequest request,
    required String teamId,
    required String token,
  });

  // Future<Either<ErrorResponse, Item>> createItem({
  //   required Item item,
  //   required String teamId,
  //   required String token,
  // });
  Future<Either<ErrorResponse, Item>> getItem({
    required String itemId,
    required String teamId,
    required String token,
  });
  Future<Either<ErrorResponse, Unit>> createItemImage({
    required ItemImageRequest request,
    required String token,
  });

  Future<Either<ErrorResponse, Unit>> upsertItemVariationImage({
    required ItemVariationImageRequest request,
    required String token,
  });
  Future<Either<ErrorResponse, Unit>> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  });
  Future<Either<ErrorResponse, Item>> updateItem({
    required ItemUpdatePayload payload,
    required String itemId,
    required String teamId,
    required String token,
  });
  Future<Either<ErrorResponse, Unit>> deleteItem({
    required String itemId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, Unit>> deleteItemVariation({
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, ItemVariation>> getItemVariation({
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, List<ItemVariation>>> getItemVariations({
    required String itemId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, ItemUtilization>> getItemUtilization({
    required String teamId,
    required String token,
  });
}
