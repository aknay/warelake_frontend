import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/item/entities.dart';

abstract class ItemUtilizationApi {
  Future<Either<ErrorResponse, ItemUtilization>> getItemUtilization({
    required String teamId,
    required String token,
  });
}
