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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.repository.g.dart';

class UserRepository extends UserApi {
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

  @override
  Future<Either<ErrorResponse, User>> getUser({required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.get(url: ApiEndPoint.getCurrentUserEndPoint, token: token, teamId: teamId);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(User.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
UserApi userRepository(UserRepositoryRef ref) {
  return UserRepository();
}
