import 'dart:io';

class ItemVariationImageRequest {
  String itemId;
  String itemVariationId;
  String teamId;
  File imagePath;
  String? imageId;
  String? imageName;

  ItemVariationImageRequest({
    required this.itemId,
    required this.itemVariationId,
    required this.teamId,
    required this.imagePath,
    this.imageId,
    this.imageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_variation_id': itemVariationId,
      // 'image_id': imageId,
      'image_name': imageName,
    };
  }

  // factory ItemVariationImageRequest.fromJson(Map<String, dynamic> json) {
  //   itemId = json['item_id'];
  //   itemVariationId = json['item_variation_id'];
  //   imageId = json['image_id'];
  //   imageName = json['image_name'];
  //   return ItemVariationImageRequest(itemId: itemId, itemVariationId: itemVariationId)

  // }
}
