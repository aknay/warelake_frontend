import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/team/api.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team.repository.g.dart';

class TeamRepository extends TeamApi {
  @override
  Future<Either<ErrorResponse, Team>> create({required Team team, required String token}) async {
    try {
      final response = await HttpHelper.post(url: ApiEndPoint.getTeamEndPoint(), body: team.toJson(), token: token);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(Team.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Team>> get({required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.get(url: ApiEndPoint.getTeamEndPoint(teamId: teamId), token: token);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(Team.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<Team>>> list({required String token}) async {
    try {
      final response = await HttpHelper.get(url: ApiEndPoint.getTeamEndPoint(), token: token);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), Team.fromJson);
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
TeamApi teamRepository(TeamRepositoryRef ref) {
  return TeamRepository();
}
