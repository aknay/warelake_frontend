import 'package:dartz/dartz.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';

abstract class BillAccountApi {
  // Future<Either<ErrorResponse, BillAccount>> create({required BillAccount account, required String token});
  Future<Either<ErrorResponse, ListResponse<BillAccount>>> list({required String teamId,  required String token});
  // Future<Either<ErrorResponse, BillAccount>> update(
  //     {required String existingAccountId, required AccountUpdateRequest request, required String token});
  // Future<Either<ErrorResponse, Unit>> delete({required String existingAccountId, required Token token});
  Future<Either<ErrorResponse, BillAccount>> get({required String billAccountId, required String teamId,  required String token});
}
