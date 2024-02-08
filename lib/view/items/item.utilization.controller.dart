import 'package:warelake/data/item/item.service.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.utilization.controller.g.dart';

@riverpod
Future<ItemUtilization> itemUtilizationController(ItemUtilizationControllerRef ref) async {
  final itemOrError = await ref.watch(itemServiceProvider).itemUtilization;

  if (itemOrError.isRight()) {
    return itemOrError.toIterable().first;
  }
  throw Exception('unable to get item utilization');
}
