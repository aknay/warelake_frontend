import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/data/auth/firebase.auth.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/item/requests.dart';

part 'item.image.service.g.dart';

final imagePickerProvider = Provider((_) => ImagePicker());

class ImageUploadService {
  final ImagePicker imagePicker;
  final ItemRepository itemRepository;
  final AuthRepository authRepo;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;

  ImageUploadService(this.imagePicker, this.itemRepository, this.authRepo, this.teamIdSharedRefRepository);

  Future<XFile?> pickImageByGallary() async {
    return await imagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<Either<String, Unit>> uploadImage({required File file, required String itemId}) async {
    final teamIdOrNone = teamIdSharedRefRepository.existingTeamId;
    if (teamIdOrNone.isNone()) {
      throw Exception('team id cannot be none');
    }
    final iir = ItemImageRequest(imagePath: file, itemId: itemId, teamId: teamIdOrNone.toNullable()!);

    final token = await authRepo.shouldGetToken();
    final createdOrError = await itemRepository.createItemImage(request: iir, token: token);
    return createdOrError.fold((l) => left(l.message), (r) => right(unit));
  }

  Future<Either<String, Unit>> upsertItemVariationImage({
    required File file,
    required String itemId,
    required String itemVariationId,
  }) async {
    final teamIdOrNone = teamIdSharedRefRepository.existingTeamId;
    if (teamIdOrNone.isNone()) {
      throw Exception('team id cannot be none');
    }
    final ivmr = ItemVariationImageRequest(
      imagePath: file,
      itemId: itemId,
      teamId: teamIdOrNone.toNullable()!,
      itemVariationId: itemVariationId,
    );

    final token = await authRepo.shouldGetToken();
    final createdOrError = await itemRepository.upsertItemVariationImage(request: ivmr, token: token);
    return createdOrError.fold((l) => left(l.message), (r) => right(unit));
  }
}

@Riverpod(keepAlive: true)
ImageUploadService imageUploadService(ImageUploadServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final itemRepo = ref.watch(itemRepositoryProvider);
  final imagePicker = ref.watch(imagePickerProvider);
  return ImageUploadService(imagePicker, itemRepo, authRepo, teamIdSharedRefRepo);
}
