import 'dart:io';

import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item/entities.dart';

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

class ItemVariationImageRequest {
  String itemId;
  String itemVariationId;
  String teamId;

  File imagePath;
  String? imageId;
  String? imageName;

  ItemVariationImageRequest({
    required this.itemId,
    required this.teamId,
    required this.imagePath,
    required this.itemVariationId,
    this.imageId,
    this.imageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_variation_id': itemVariationId,
      'image_name': imageName,
    };
  }
}

class CreateItemRequest {
  Item item;
  List<ItemVariation> itemVariations;

  CreateItemRequest({
    required this.item,
    required this.itemVariations,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'item_variations': itemVariations.map((e) => e.toJson()).toList(),
    };
  }
}
