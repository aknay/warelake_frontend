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
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => const BarcodeScannerPage(),
            ),
          );
        },
        icon: const FaIcon(FontAwesomeIcons.barcode));
  }
}

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  final controller = MobileScannerController(
    detectionTimeoutMs: 500,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  //Ref: https://github.com/breez/breezmobile/blob/276ca2fdbbdd76cb779ec62280f15e456b39462e/lib/routes/qr_scan.dart#L22
  //we need to guard with opped variable so that it will not pop more than one time.
  var popped = false;
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            if (popped || !mounted) {
              return;
            }
            popped = true;
            ref.read(barcodeScannerValueControllerProvider.notifier).setBarcode(barcodes.first.rawValue);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
