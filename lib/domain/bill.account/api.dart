import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';

abstract class BillAccountApi {
  // Future<Either<ErrorResponse, BillAccount>> create({required BillAccount account, required String token});
  Future<Either<ErrorResponse, ListResponse<BillAccount>>> list({required String teamId,  required String token});
  // Future<Either<ErrorResponse, BillAccount>> update(
  //     {required String existingAccountId, required AccountUpdateRequest request, required String token});
  // Future<Either<ErrorResponse, Unit>> delete({required String existingAccountId, required Token token});
  // Future<Either<ErrorResponse, BillAccount>> get({required String existingAccountId, required Token token});
}
