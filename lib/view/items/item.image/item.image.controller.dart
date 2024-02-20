import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/item/item.image.service.dart';
import 'package:warelake/data/item/item.service.dart';

part 'item.image.controller.g.dart';

@Riverpod(keepAlive: true)
class ItemImageController extends _$ItemImageController {
  @override
  Future<Option<String>> build({required String itemId}) async {
    return await _getItemImageUrlOrNone(itemId: itemId);
  }

  Future<void> pickImage() async {
    final fileOrNull = await ref.read(imageUploadServiceProvider).pickImageByGallary(itemId: itemId);
    if (fileOrNull != null) {
      state = const AsyncLoading();
      final uploadOrError = await ref.read(imageUploadServiceProvider).uploadImage(file: fileOrNull, itemId: itemId);
      uploadOrError.fold((l) {
        state = AsyncValue.error('Faile to upload an image', StackTrace.current);
      }, (r) async {
        state = AsyncValue.data(await _getItemImageUrlOrNone(itemId: itemId));
      });
    }
  }

  Future<Option<String>> _getItemImageUrlOrNone({required String itemId}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final itemOrError = await ref.read(itemServiceProvider).getItem(itemId: itemId);
    if (itemOrError.isRight()) {
      return optionOf(itemOrError.toIterable().first.imageUrl);
    }
    throw Exception('unable to get item utilization');
  }
}
