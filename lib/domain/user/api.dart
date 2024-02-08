import 'package:dartz/dartz.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/team/entities.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/user/valueobject.dart';

abstract class UserApi {
  Future<Either<ErrorResponse, ListResponse<User>>> getUserList({required Team team, required String token});
  Future<Either<ErrorResponse, User>> getUser({required String teamId, required String token});
}
