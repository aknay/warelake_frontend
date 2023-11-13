import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/role/entities.dart';

abstract class RoleApi {
  Future<Either<ErrorResponse, ListResponse<Role>>> getRoleList({required String teamId, required String token});
}
