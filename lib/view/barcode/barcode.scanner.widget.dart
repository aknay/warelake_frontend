import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warelake/view/barcode/barcode.scanner.value.controller.dart';

class BarcodeScannerWidget extends ConsumerWidget {
  const BarcodeScannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
          );
        },
        icon: const FaIcon(FontAwesomeIcons.barcode));
  }
}

class BarcodeScannerPage extends ConsumerWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            ref.read(barcodeScannerValueControllerProvider.notifier).setBarcode(barcode.rawValue);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
