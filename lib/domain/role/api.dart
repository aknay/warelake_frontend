import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/role/entities.dart';

abstract class RoleApi {
  Future<Either<ErrorResponse, ListResponse<Role>>> getRoleList({required String teamId, required String token});
}
