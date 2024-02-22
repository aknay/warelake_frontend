import 'dart:io';

class ItemImageRequest {
  String itemId;
  String teamId;
  File imagePath;
  String? imageId;
  String? imageName;

  ItemImageRequest({
    required this.itemId,
    required this.teamId,
    required this.imagePath,
    this.imageId,
    this.imageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'image_name': imageName,
    };
  }
}
