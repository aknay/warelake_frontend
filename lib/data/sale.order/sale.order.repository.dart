import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/sale.order/api.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/sale.order/payloads.dart';
import 'package:warelake/domain/sale.order/search.field.dart';

part 'sale.order.repository.g.dart';

class SaleOrderRepository extends SaleOrderApi {
  SaleOrderRepository();

  @override
  Future<Either<ErrorResponse, Unit>> setToDelivered({
    required String saleOrderId,
    required DateTime date,
    required String teamId,
    required String token,
  }) async {
    try {
      final payload = SaleOrderUpdatePayload.create(date: date);

      final response = await HttpHelper.post(
          url: ApiEndPoint.getDelieveredItemsSaleOrderEndPoint(saleOrderId: saleOrderId),
          body: payload.toMap(),
          token: token,
          teamId: teamId);
      log("sale order delivered response code ${response.statusCode}");
      log("sale order delivered  response ${jsonDecode(response.body)}");
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
  Future<Either<ErrorResponse, SaleOrder>> create(
      {required SaleOrder saleOrder, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getSaleOrderEndPoint(), body: saleOrder.toJson(), token: token, teamId: teamId);

      if (response.statusCode == 201) {
        return Right(SaleOrder.fromJson(jsonDecode(response.body)));
      }
      Logger().e("sale order create response code ${response.statusCode}");
      Logger().e("sale order create response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      Logger().e(e);
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<SaleOrder>>> list(
      {required String teamId, required String token, SaleOrderSearchField? searchField}) async {
    try {
      final response = await HttpHelper.get(
        url: ApiEndPoint.getSaleOrderEndPoint(),
        token: token,
        teamId: teamId,
        additionalQuery: searchField?.toMap(),
      );

      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), SaleOrder.fromJson);
        return Right(listResponse);
      }
      log("list sale order response code ${response.statusCode}");
      log("list sale order response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, SaleOrder>> get(
      {required String saleOrderId, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getSaleOrderEndPoint(saleOrderId: saleOrderId), token: token, teamId: teamId);
      log("sale order get response code ${response.statusCode}");
      log("sale order get response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(SaleOrder.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> delete(
      {required String saleOrderId, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.delete(
          url: ApiEndPoint.getSaleOrderEndPoint(saleOrderId: saleOrderId), token: token, teamId: teamId);
      log("sale order deleted response code ${response.statusCode}");
      log("sale order deleted  response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
SaleOrderRepository saleOrderRepository(SaleOrderRepositoryRef ref) {
  return SaleOrderRepository();
}
