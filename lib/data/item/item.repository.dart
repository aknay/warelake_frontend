import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/item/api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payload.item.dart';
import 'package:inventory_frontend/domain/item/requests.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.repository.g.dart';

class ItemRepository extends ItemApi {
  ItemRepository();

  @override
  Future<Either<ErrorResponse, Item>> createItem(
      {required Item item, required String teamId, required String token}) async {
    try {
      final response =
          await HttpHelper.post(url: ApiEndPoint.getItemEndPoint(), body: item.toJson(), token: token, teamId: teamId);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({
    required String teamId,
    required String token,
    String? startingAfterItemId,
  }) async {
    try {
      Map<String, String> additionalQuery = {};
      if (startingAfterItemId != null) {
        additionalQuery["starting_after"] = startingAfterItemId;
      }

      final response = await HttpHelper.get(
        url: ApiEndPoint.getItemEndPoint(),
        token: token,
        teamId: teamId,
        additionalQuery: additionalQuery,
      );

      log("item list response code ${response.statusCode}");
      log("item list response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), Item.fromJson);
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
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Item>> createImage(
      {required ItemVariationImageRequest request, required String token}) async {
    final response = await HttpHelper.postImage(
        url: ApiEndPoint.getItemImageEndPoint(),
        imageFile: request.imagePath,
        token: token,
        body: request.toJson(),
        teamId: request.teamId);
    if (response.statusCode == 200) {
      log('Image uploaded successfully');
      log(await response.stream.bytesToString());
    } else {
      log('Image upload failed with status ${response.statusCode}');
    }

    // var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

    // TODO: implement createImage
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorResponse, Item>> editVariation({required ItemVariation itemVariation, required String token}) {
    // TODO: implement editVariation
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorResponse, Item>> editItem(
      {required PayloadItem payloadItem, required String itemId, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getItemEndPoint(itemId: itemId), token: token, teamId: teamId, body: payloadItem.toMap());
      log("get item response code ${response.statusCode}");
      log("get item response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
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
  Future<Either<ErrorResponse, Unit>> deelteItemVariation({
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
}

@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository();
}
