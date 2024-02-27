import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/items/item.variation.image/item.variation.image.controller.dart';

class ItemVariationImageWidget extends ConsumerWidget {
  final String itemId;
  final String itemVariationId;
  final bool isForTheList;
  const ItemVariationImageWidget(
      {super.key, required this.itemId, required this.itemVariationId, required this.isForTheList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(itemVariationImageControllerProvider(itemId: itemId, itemVariationId: itemVariationId));
    final imageSize = isForTheList ? 48.0 : 70.0;
    final f = imageUrl.when(data: (data) {
      return data.fold(() {
        return SizedBox(
            width: imageSize,
            height: imageSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey,
              ),
            ));
      }, (a) {
        final imageUrl = kDebugMode ? replaceIpAddress(a, '10.0.2.2') : a;

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const CircleAvatar(
              backgroundColor: Colors.amber,
              radius: 40,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      });
    }, error: (object, error) {
      return const Text('error');
    }, loading: () {
      return const CircularProgressIndicator();
    });
    final onClick = isForTheList
        ? null
        : ref
            .read(itemVariationImageControllerProvider(itemId: itemId, itemVariationId: itemVariationId).notifier)
            .pickImage;
    return GestureDetector(onTap: onClick, child: f);
  }

  String replaceIpAddress(String originalUrl, String newIpAddress) {
    List<String> parts = originalUrl.split(':');
    String protocol = parts[0];
    String portPart = parts.last;
    return '$protocol://$newIpAddress:$portPart';
  }
}
