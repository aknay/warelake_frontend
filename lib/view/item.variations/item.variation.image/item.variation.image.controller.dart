import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/item/item.image.service.dart';
import 'package:warelake/data/item/item.service.dart';

part 'item.variation.image.controller.g.dart';

@Riverpod(keepAlive: true)
class ItemVariationImageController extends _$ItemVariationImageController {
  @override
  Future<Option<String>> build({required String itemId, required String itemVariationId}) async {
    return await _getItemVariationImageUrlOrNone(itemId: itemId, itemVariationId: itemVariationId);
  }

  Future<void> pickImage() async {
    final fileOrNull = await ref.read(imageUploadServiceProvider).pickImageByGallary();
    if (fileOrNull != null) {
      state = const AsyncLoading();
      final resizedImageOrError = _compressAndResizeImage(File(fileOrNull.path));
      if (resizedImageOrError.isLeft()) {
        state = AsyncValue.error('Faile to resize iamge', StackTrace.current);
        return;
      }

      final uploadOrError = await ref
          .read(imageUploadServiceProvider)
          .upsertItemVariationImage(file: resizedImageOrError.toIterable().first, itemId: itemId, itemVariationId: itemVariationId);
      uploadOrError.fold((l) {
        state = AsyncValue.error('Faile to upload an image', StackTrace.current);
      }, (r) async {
        state = AsyncValue.data(await _getItemVariationImageUrlOrNone(itemId: itemId, itemVariationId: itemVariationId));
      });
    }
  }

  Future<Option<String>> _getItemVariationImageUrlOrNone({required String itemId, required String itemVariationId}) async {
    if (kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
    }
    final itemOrError = await ref.read(itemServiceProvider).getItem(itemId: itemId);
    return itemOrError.fold((l) => throw Exception('unable to get item'), (r) {
      final itemVariations = r.variations.where((element) => element.id == itemVariationId);
      if (itemVariations.isEmpty) throw Exception('item variation is empty');
      return optionOf(itemVariations.first.imageUrl);
    });
  }

  Either<String, File> _compressAndResizeImage(File file) {
    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) {
      return left('unable to decode image');
    }

    img.Image resizedImage = img.copyResize(image, width: 200, height: 200);

    // Compress the image with JPEG format
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 70);

    // Save the compressed image to a file
    File compressedFile = File(file.path.replaceFirst('.jpg', '_compressed.jpg'));
    compressedFile.writeAsBytesSync(compressedBytes);

    return right(compressedFile);
  }
}
