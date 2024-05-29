import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class AppVersionText extends ConsumerWidget {
  const AppVersionText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    return packageInfo.when(
        data: (PackageInfo data) => Text("version ${data.version}"),
        error: (Object error, StackTrace stackTrace) => const Text('Error'),
        loading: () => const CircularProgressIndicator());
  }
}
