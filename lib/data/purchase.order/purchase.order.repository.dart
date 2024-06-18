import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/purchase.order/api.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/purchase.order/payloads.dart';
import 'package:warelake/domain/purchase.order/search.field.dart';
import 'package:warelake/domain/responses.dart';

part 'purchase.order.repository.g.dart';

class PurchaseOrderRepository extends PurchaseOrderApi {
  @override
  Future<Either<ErrorResponse, PurchaseOrder>> setToIssued(
      {required PurchaseOrder purchaseOrder, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getPurchaseOrderEndPoint(), body: purchaseOrder.toJson(), token: token, teamId: teamId);
      log("purchase order create response code ${response.statusCode}");
      log("purchase order create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(PurchaseOrder.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      Logger().e("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, PurchaseOrder>> setToReceived(
      {required String purchaseOrderId, required DateTime date, required String teamId, required String token}) async {
    try {
      final payload = PurchaseOrderUpdatePayload.create(date: date);

      final response = await HttpHelper.post(
          url: ApiEndPoint.getReceivedItemsPurchaseOrderEndPoint(purchaseOrderId: purchaseOrderId),
          body: payload.toMap(),
          token: token,
          teamId: teamId);
      log("purchase order create response code ${response.statusCode}");
      log("purchase order create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(PurchaseOrder.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> delete(
      {required String purchaseOrderId, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.delete(
          url: ApiEndPoint.getPurchaseOrderEndPoint(purchaseOrderId: purchaseOrderId), token: token, teamId: teamId);
      log("sale order get response code ${response.statusCode}");
      log("sale order get response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, PurchaseOrder>> get(
      {required String purchaseOrderId, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getPurchaseOrderEndPoint(purchaseOrderId: purchaseOrderId), token: token, teamId: teamId);

      if (response.statusCode == 200) {
        return Right(PurchaseOrder.fromJson(jsonDecode(response.body)));
      }
      log("sale order get response code ${response.statusCode}");
      log("sale order get response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<PurchaseOrder>>> list({
    required String teamId,
    required String token,
    PurchaseOrderSearchField? searchField,
  }) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getPurchaseOrderEndPoint(),
          token: token,
          teamId: teamId,
          additionalQuery: searchField?.toMap());

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), PurchaseOrder.fromJson);
        return Right(listResponse);
      }
      log("list purchase order response code ${response.statusCode}");
      log("list purchase order response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
PurchaseOrderRepository purchaseOrderRepository(PurchaseOrderRepositoryRef ref) {
  return PurchaseOrderRepository();
}
