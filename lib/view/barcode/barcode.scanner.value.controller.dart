import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barcode.scanner.value.controller.g.dart';

@riverpod
class BarcodeScannerValueController extends _$BarcodeScannerValueController {
  @override
  Option<String> build() {
    return const None();
  }

  void setBarcode(String? value) {
    state = optionOf(value);
  }
}
