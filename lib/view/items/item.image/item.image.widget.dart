import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/items/item.image/item.image.controller.dart';

class ItemImageWidget extends ConsumerWidget {
  final String itemId;

  final bool isForTheList;
  const ItemImageWidget({super.key, required this.itemId, required this.isForTheList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(itemImageControllerProvider(itemId: itemId));
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
                // shape: BoxShape.circle,
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
    final onClick = isForTheList ? null : ref.read(itemImageControllerProvider(itemId: itemId).notifier).pickImage;
    return GestureDetector(onTap: onClick, child: f);
  }

  String replaceIpAddress(String originalUrl, String newIpAddress) {
    // Split the original URL by ':'
    List<String> parts = originalUrl.split(':');

    // Extract the protocol and port part
    String protocol = parts[0];
    String portPart = parts.last;

    // Replace the IP address with the new one
    String replacedUrl = '$protocol://$newIpAddress:$portPart';

    return replacedUrl;
  }
}
