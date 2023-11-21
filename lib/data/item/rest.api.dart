import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/item/api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/requests.dart';
import 'package:inventory_frontend/domain/responses.dart';

class ItemRestApi extends ItemApi {
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
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({required String teamId, required String token}) {
    // TODO: implement getItemList
    throw UnimplementedError();
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
    print(await response.stream.bytesToString());
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      print(await response.stream.bytesToString());
    } else {
      print('Image upload failed with status ${response.statusCode}');
    }

    // var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

    // TODO: implement createImage
    throw UnimplementedError();
  }
}
