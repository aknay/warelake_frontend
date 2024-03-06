import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/item/api.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

part 'item.repository.g.dart';

class ItemRepository extends ItemApi {
  ItemRepository();

  @override
  Future<Either<ErrorResponse, Item>> createItem(
      {required Item item, required String teamId, required String token}) async {
    try {
      final response =
          await HttpHelper.post(url: ApiEndPoint.getItemEndPoint(), body: item.toJson(), token: token, teamId: teamId);

      if (response.statusCode == 201) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      log("error while creating an item: response code ${response.statusCode}");
      log("error while creating an item: response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.fromJson(json: jsonDecode(response.body), statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({
    required String teamId,
    required String token,
    ItemSearchField? itemSearchField,
  }) async {
    try {
      Map<String, String> additionalQuery = {};
      if (itemSearchField != null) {
        if (itemSearchField.startingAfterItemId != null) {
          additionalQuery["starting_after"] = itemSearchField.startingAfterItemId!;
        }
        if (itemSearchField.itemName != null) {
          additionalQuery["item_name"] = itemSearchField.itemName!;
        }
      }
      log("additional query $additionalQuery");
      final response = await HttpHelper.get(
        url: ApiEndPoint.getItemEndPoint(),
        token: token,
        teamId: teamId,
        additionalQuery: additionalQuery,
      );

      log("item list response code ${response.statusCode}");
      // log("item list response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), Item.fromJson);
        log("the response ${listResponse.data.length}");
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Item>> getItem(
      {required String itemId, required String teamId, required String token}) async {
    try {
      final response =
          await HttpHelper.get(url: ApiEndPoint.getItemEndPoint(itemId: itemId), token: token, teamId: teamId);

      if (response.statusCode == 200) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> createItemImage(
      {required ItemImageRequest request, required String token}) async {
    final response = await HttpHelper.postImage(
        url: ApiEndPoint.getItemImageEndPoint(itemId: request.itemId),
        imageFile: request.imagePath,
        token: token,
        body: request.toJson(),
        teamId: request.teamId);
    if (response.statusCode == 200) {
      return right(unit);
    } else {
      log('Image upload failed with status ${response.statusCode}');
    }
    return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
  }

  @override
  Future<Either<ErrorResponse, Item>> updateItem(
      {required ItemUpdatePayload payload,
      required String itemId,
      required String teamId,
      required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getItemEndPoint(itemId: itemId), token: token, teamId: teamId, body: payload.toMap());
      if (response.statusCode == 200) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      log("error while updating item: response code ${response.statusCode}");
      log("error while updating item: response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> deleteItem(
      {required String itemId, required String teamId, required String token}) async {
    try {
      final response =
          await HttpHelper.delete(url: ApiEndPoint.getItemEndPoint(itemId: itemId), token: token, teamId: teamId);
      log("delete item response code ${response.statusCode}");
      log("delete item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> deleteItemVariation({
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.delete(
          url: ApiEndPoint.getItemVariationEndPoint(itemId: itemId, itemVariationId: itemVariationId),
          token: token,
          teamId: teamId);
      log("delete item response code ${response.statusCode}");
      log("delete item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getItemVariationEndPoint(itemId: itemId, itemVariationId: itemVariationId),
          token: token,
          teamId: teamId,
          body: payload.toMap());
      log("update item variation response code ${response.statusCode}");
      log("update item variation response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ItemUtilization>> getItemUtilization(
      {required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.get(url: ApiEndPoint.itemUtilizationEndPoint, token: token, teamId: teamId);
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(ItemUtilization.fromMap(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> upsertItemVariationImage(
      {required ItemVariationImageRequest request, required String token}) async {
    final response = await HttpHelper.postImage(
        url:
            ApiEndPoint.getItemVariationImageEndPoint(itemId: request.itemId, itemVariationId: request.itemVariationId),
        imageFile: request.imagePath,
        token: token,
        body: request.toJson(),
        teamId: request.teamId);
    if (response.statusCode == 200) {
      return right(unit);
    } else {
      log('Image upload failed with status ${response.statusCode}');
    }
    return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
  }

  @override
  Future<Either<ErrorResponse, ListResponse<ItemVariation>>> getItemVariationList(
      {required String teamId, required String token, ItemVariationSearchField? searchField}) async {
    try {
      final response = await HttpHelper.get(
        url: ApiEndPoint.getItemVariationsEndPoint,
        token: token,
        teamId: teamId,
        additionalQuery: searchField?.toMap(),
      );

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), ItemVariation.fromJson);
        log("the response ${listResponse.data.length}");
        return Right(listResponse);
      }
      log("item list response code ${response.statusCode}");
      log("item list response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository();
}
