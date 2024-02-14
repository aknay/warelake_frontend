import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/team/api.dart';
import 'package:warelake/domain/team/entities.dart';

part 'team.repository.g.dart';

class TeamRepository extends TeamApi {
  @override
  Future<Either<ErrorResponse, Team>> create({required Team team, required String token}) async {
    try {
      final response = await HttpHelper.post(url: ApiEndPoint.getTeamEndPoint(), body: team.toJson(), token: token);
      if (response.statusCode == 201) {
        return Right(Team.fromJson(jsonDecode(response.body)));
      }
      log("error while creating a team: response code ${response.statusCode}");
      log("error while creating a team: response ${jsonDecode(response.body)}");
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

      if (response.statusCode == 201) {
        return Right(Team.fromJson(jsonDecode(response.body)));
      }
      log("error while getting a team: response code ${response.statusCode}");
      log("error while getting a team: response ${jsonDecode(response.body)}");
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
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), Team.fromJson);
        return Right(listResponse);
      }
      log("error while listing team: response code ${response.statusCode}");
      log("error while list team: response ${jsonDecode(response.body)}");
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
