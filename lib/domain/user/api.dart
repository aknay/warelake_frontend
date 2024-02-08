import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/user/valueobject.dart';

abstract class UserApi {
  Future<Either<ErrorResponse, ListResponse<User>>> getUserList({required Team team, required String token});
  Future<Either<ErrorResponse, User>> getUser({required String teamId, required String token});
}
