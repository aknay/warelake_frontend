import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/purchase.order/search.field.dart';
import 'package:warelake/domain/responses.dart';

abstract class PurchaseOrderApi {
  Future<Either<ErrorResponse, PurchaseOrder>> setToIssued({
    required PurchaseOrder purchaseOrder,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, PurchaseOrder>> setToReceived({
    required String purchaseOrderId,
    required DateTime date,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, Unit>> delete({
    required String purchaseOrderId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, PurchaseOrder>> get({
    required String purchaseOrderId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, ListResponse<PurchaseOrder>>> list({
    required String teamId,
    required String token,
    PurchaseOrderSearchField? searchField,
  });
}
