import 'package:dartz/dartz.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/team/entities.dart';
import 'package:warelake/domain/errors/response.dart';

abstract class TeamApi {
  Future<Either<ErrorResponse, Team>> create({required Team team, required String token});
  Future<Either<ErrorResponse, Team>> get({required String teamId, required String token});
  Future<Either<ErrorResponse,  ListResponse<Team>>> list({required String token});
}
