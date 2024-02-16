import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/role/api.dart';
import 'package:warelake/domain/role/entities.dart';

class RoleRestApi extends RoleApi {
  @override
  Future<Either<ErrorResponse, ListResponse<Role>>> getRoleList({required String teamId, required String token}) async {
    try {
      Map<String, String> map = {};
      map["team_id"] = teamId;
      final response = await HttpHelper.getWithQuery(url: ApiEndPoint.getRoleEndPoint(), token: token, query: map);

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), Role.fromJson);
        return Right(listResponse);
      }
      log("error while list roles: response code ${response.statusCode}");
      log("error while listing roles: response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}
