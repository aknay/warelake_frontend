import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/domain/item/entities.dart';

final selectedLineItemProvider = StateProvider.autoDispose<Option<ItemVariation>>(
  (ref) => const None(),
);
