import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:inventory_frontend/domain/errors/response.dart';

abstract class TeamApi {
  Future<Either<ErrorResponse, Team>> create({required Team team, required String token});
}
