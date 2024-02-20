import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/items/item.image/item.image.controller.dart';

class ItemImageWidget extends ConsumerWidget {
  final String itemId;
  const ItemImageWidget({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(itemImageControllerProvider(itemId: itemId));

    final f = imageUrl.when(data: (data) {
      return data.fold(() {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20), // Image border
          child: SizedBox.fromSize(
              size: const Size.fromRadius(48), // Image radius
              child: const Icon(
                Icons.camera_alt,
                size: 48,
              )),
        );
      }, (a) {
        final imageUrl = kDebugMode ? replaceIpAddress(a, '10.0.2.2') : a;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20), // Image border
          child: SizedBox.fromSize(
            size: const Size.fromRadius(48), // Image radius
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        );
      });
    }, error: (object, error) {
      return const Text('error');
    }, loading: () {
      return const CircularProgressIndicator();
    });

    return GestureDetector(
        child: f,
        onTap: () {
          ref.read(itemImageControllerProvider(itemId: itemId).notifier).pickImage();
        });
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
