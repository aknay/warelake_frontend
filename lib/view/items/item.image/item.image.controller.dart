import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
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
      final resizedImageOrError = _compressAndResizeImage(File(fileOrNull.path));
      if (resizedImageOrError.isLeft()) {
        state = AsyncValue.error('Faile to resize iamge', StackTrace.current);
        return;
      }

      final uploadOrError = await ref.read(imageUploadServiceProvider).uploadImage(file: resizedImageOrError.toIterable().first, itemId: itemId);
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
