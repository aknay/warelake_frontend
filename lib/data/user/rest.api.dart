import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:inventory_frontend/domain/user/api.dart';
import 'package:inventory_frontend/domain/user/valueobject.dart';

class UserRestApi extends UserApi {
  @override
  Future<Either<ErrorResponse, ListResponse<User>>> getUserList({required Team team, required String token}) async {
    try {
      Map<String, String> map = {};
      map["team_id"] = team.id!;
      final response = await HttpHelper.getWithQuery(url: ApiEndPoint.getUserEndPoint(), token: token, query: map);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), User.fromJson);
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}
