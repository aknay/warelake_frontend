import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item.variation/api.dart';
import 'package:warelake/domain/item.variation/payloads.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/responses.dart';

part 'item.variation.repository.g.dart';

class ItemVariationRepository extends ItemVariationApi {
  ItemVariationRepository();

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
          url: ApiEndPoint.getItemVariationEndPoint(
              itemId: itemId, itemVariationId: itemVariationId),
          token: token,
          teamId: teamId,
          body: payload.toMap());
      log("update item variation response code ${response.statusCode}");
      log("update item variation response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> upsertItemVariationImage(
      {required ItemVariationImageRequest request,
      required String token}) async {
    final response = await HttpHelper.postImage(
        url: ApiEndPoint.getItemVariationImageEndPoint(
            itemId: request.itemId, itemVariationId: request.itemVariationId),
        imageFile: request.imagePath,
        token: token,
        body: request.toJson(),
        teamId: request.teamId);
    if (response.statusCode == 200) {
      return right(unit);
    } else {
      log('Image upload failed with status ${response.statusCode}');
    }
    return Left(ErrorResponse.withStatusCode(
        message: "having error", statusCode: response.statusCode));
  }

  @override
  Future<Either<ErrorResponse, ListResponse<ItemVariation>>>
      getItemVariationList(
          {required String teamId,
          required String token,
          ItemVariationSearchField? searchField}) async {
    try {
      final response = await HttpHelper.get(
        url: ApiEndPoint.getItemVariationsEndPoint,
        token: token,
        teamId: teamId,
        additionalQuery: searchField?.toMap(),
      );

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(
            jsonDecode(response.body), ItemVariation.fromJson);
        log("the response ${listResponse.data.length}");
        return Right(listResponse);
      }
      log("item list response code ${response.statusCode}");
      log("item list response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<ItemVariation>>>
      getLowLevelItemVariationList(
          {required String teamId,
          required String token,
          Option<String> startingAfterId = const None()}) async {
    try {
      Map<String, String> additionalQuery = {};
      startingAfterId.fold(() => null, (a) {
        additionalQuery['startingAfterId'] = a;
      });

      final response = await HttpHelper.get(
        url: ApiEndPoint.getLowLevelItemVariationsEndPoint,
        token: token,
        teamId: teamId,
        additionalQuery: additionalQuery,
      );

      if (response.statusCode == 200) {
        log("item list response ${jsonDecode(response.body)}");

        final listResponse = ListResponse.fromJson(
            jsonDecode(response.body), ItemVariation.fromJson);
        log("the response ${listResponse.data.length}");
        return Right(listResponse);
      }
      log("item list response code ${response.statusCode}");
      log("item list response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<ItemVariation>>>
      getItemVariationListByItemId(
          {required String teamId,
          required String itemId,
          required String token}) async {
    try {
      Map<String, String> additionalQuery = {};
      additionalQuery['item_id'] = itemId;

      final response = await HttpHelper.get(
        url: ApiEndPoint.getItemVariationByItemIdEndPoint(itemId: itemId),
        token: token,
        teamId: teamId,
        additionalQuery: additionalQuery,
      );

      if (response.statusCode == 200) {
        log("item list response ${jsonDecode(response.body)}");

        final listResponse = ListResponse.fromJson(
            jsonDecode(response.body), ItemVariation.fromJson);
        log("the response ${listResponse.data.length}");
        return Right(listResponse);
      }
      log("item list response code ${response.statusCode}");
      log("item list response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ItemVariation>> getItemVariation(
      {required String itemId,
      required String itemVariationId,
      required String teamId,
      required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getItemVariationEndPoint(
              itemId: itemId, itemVariationId: itemVariationId),
          token: token,
          teamId: teamId);

      if (response.statusCode == 200) {
        return Right(ItemVariation.fromJson(jsonDecode(response.body)));
      }
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      Logger().e(e);
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, List<ItemVariation>>> getItemVariations(
      {required String itemId,
      required String teamId,
      required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getItemVariationEndPoint(itemId: itemId),
          token: token,
          teamId: teamId);

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(
            jsonDecode(response.body), ItemVariation.fromJson);

        return Right(listResponse.data);
      }

      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
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
          url: ApiEndPoint.getItemVariationEndPoint(
              itemId: itemId, itemVariationId: itemVariationId),
          token: token,
          teamId: teamId);
      log("delete item response code ${response.statusCode}");
      log("delete item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<ItemVariation>>>
      getExpiringItemVariations(
          {required String teamId,
          required String token,
          required DateTime expiryDate,
          Option<String> startingAfterId = const None()}) async {
    try {
      Map<String, String> additionalQuery = {};
      additionalQuery["expiry_date"] = expiryDate.toUtc().toIso8601String();
      startingAfterId.fold(() => null, (a) {
        additionalQuery['starting_after'] = a;
      });
      final response = await HttpHelper.get(
          url: ApiEndPoint.getExpiredItemVariationsEndPoint(expiryDate),
          token: token,
          teamId: teamId,
          additionalQuery: additionalQuery);

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(
            jsonDecode(response.body), ItemVariation.fromJson);

        return Right(listResponse);
      }
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(
          message: "having error", statusCode: response.statusCode));
    } catch (e) {
      Logger().e(e);
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
ItemVariationRepository itemVariationRepository(
    ItemVariationRepositoryRef ref) {
  return ItemVariationRepository();
}
