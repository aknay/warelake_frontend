import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/common/entities.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item.variation/payloads.dart';
import 'package:warelake/view/barcode/barcode.scanner.value.controller.dart';
import 'package:warelake/view/barcode/barcode.scanner.widget.dart';
import 'package:warelake/view/common.widgets/responsive.center.dart';
import 'package:warelake/view/common.widgets/widgets/date.selection.widget.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/constants/breakpoints.dart';
import 'package:warelake/view/utils/currency.input.formatter.dart';

class AddItemVariationScreen extends ConsumerStatefulWidget {
  const AddItemVariationScreen({super.key, this.itemVariation = const None(), this.hideStockLevelUi});
  final Option<ItemVariation> itemVariation;
  final bool? hideStockLevelUi;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemVariationScreenState();
}

class _AddItemVariationScreenState extends ConsumerState<AddItemVariationScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemVariationName = const None();
  Option<double> purchasingPrice = const None();
  Option<double> sellingPrice = const None();
  Option<String> barcodeOrNone = const None();
  Option<double> currentStockLevel = const Some(0);
  Option<int> minimumStockLevelOrNone = const Some(0);
  Option<DateTime> expiryDateOrNone = const None();
  late final CurrencyCode currencyCode;
  late final currencyFormatter = CurrencyTextInputFormatter(currencyCode: currencyCode);
  late final bool hideStockLevelUi = widget.hideStockLevelUi == null ? false : widget.hideStockLevelUi!;

  late final enableLowStockProvider = StateProvider.autoDispose<bool>((ref) {
    return widget.itemVariation.fold(() => false, (a) => a.minimumStockCountOrNone.isSome());
  });

  late final enableExpiryDateProvider = StateProvider.autoDispose<bool>((ref) {
    return widget.itemVariation.fold(() => false, (a) => a.expiryDate.isSome());
  });

  @override
  void initState() {
    super.initState();

    final currencyCodeOrNone = ref.read(teamIdSharedReferenceRepositoryProvider).currencyCode;
    currencyCode = currencyCodeOrNone.toNullable()!;
    widget.itemVariation.fold(() => null, (a) {
      itemVariationName = Some(a.name);
    });
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      if (itemVariationName.isSome() && purchasingPrice.isSome() && sellingPrice.isSome() && barcodeOrNone.isSome()) {
        final salePrice = sellingPrice.fold(() => 0.0, (a) => a);
        final salePriceMoney = PriceMoney.from(amount: salePrice, currencyCode: currencyCode);

        final purchasePrice = purchasingPrice.fold(() => 0.0, (a) => a);
        final purchasePriceMoney = PriceMoney.from(amount: purchasePrice, currencyCode: currencyCode);

        final itemCount = currentStockLevel.fold(() => 0.0, (a) => a);

        widget.itemVariation.fold(() {
          final itemVariation = ItemVariation.create(
              name: itemVariationName.fold(() => '', (a) => a),
              stockable: true,
              sku: 'abc',
              salePriceMoney: salePriceMoney,
              purchasePriceMoney: purchasePriceMoney,
              itemCount: itemCount,
              barcode: barcodeOrNone.toNullable(),
              minimumStock: minimumStockLevelOrNone,
              expiryDate: expiryDateOrNone);

          context.pop(itemVariation);
        }, (a) {
          if (!ref.read(enableLowStockProvider)) {
            minimumStockLevelOrNone =
                const Some(0); // we have to disable low stock with 0 value // the logic is a bit weird
          }

          Option<ExpiryDateOrDisable> expiryDateOrDisable;
          if (!ref.read(enableExpiryDateProvider)) {
            expiryDateOrDisable = Some(ExpiryDateOrDisable.disableExpiryDate());
          } else {
            expiryDateOrDisable =
                expiryDateOrNone.fold(() => const None(), (x) => Some(ExpiryDateOrDisable.updateExpiryDate(x)));
          }

          final payload = ItemVariationPayload(
              name: itemVariationName,
              pruchasePrice: purchasingPrice,
              salePrice: sellingPrice,
              expiryDateOrDisable: expiryDateOrDisable,
              barcode: barcodeOrNone);

          context.pop(payload);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemVariation.isNone() ? 'New Item' : 'Edit Item'),
        actions: [
          IconButton(
              onPressed: () async {
                await _submit();
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: _buildContents(),
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxContentWidth: Breakpoint.tablet,
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  Widget _barcodeTextFormField(WidgetRef ref) {
    String? initialValue = widget.itemVariation.fold(() => null, (a) => a.barcode);
    Option<String> f = ref.watch(barcodeScannerValueControllerProvider);
    f.fold(() => null, (a) => {initialValue = a});

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: UniqueKey(),
            initialValue: initialValue,
            decoration: const InputDecoration(
              labelText: 'Barcode *',
              hintText: 'Enter barcode',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter barcode';
              }
              return null;
            },
            onSaved: (value) {
              barcodeOrNone = optionOf(value);
            },
          ),
        ),
        const BarcodeScannerWidget()
      ],
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        initialValue: widget.itemVariation.fold(() => null, (a) => a.name),
        decoration: const InputDecoration(
          labelText: 'Item Name *',
          hintText: 'Item Name',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Item Name';
          }
          return null;
        },
        onSaved: (value) => itemVariationName = optionOf(value),
      ),
      Column(children: [
        gapH8,
        TextFormField(
          initialValue: widget.itemVariation.fold(() => null, (a) => a.purchasePriceMoney.amountInDouble.toString()),
          inputFormatters: <TextInputFormatter>[currencyFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Purchase Price*',
            hintText: 'Enter purchase price',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter purchase price';
            }
            return null;
          },
          onSaved: (value) => purchasingPrice = value == null ? const Some(0) : optionOf(double.tryParse(value)),
        ),
        gapH8,
        TextFormField(
          initialValue: widget.itemVariation.fold(() => null, (a) => a.salePriceMoney.amountInDouble.toString()),
          inputFormatters: <TextInputFormatter>[currencyFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Selling Price *',
            hintText: 'Enter selling price',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter selling price';
            }
            return null;
          },
          onSaved: (value) => sellingPrice = value == null ? const Some(0) : optionOf(double.tryParse(value)),
        ),
        gapH8,
        _barcodeTextFormField(ref),
        gapH8,
        Row(
          children: [
            const Text('Enable Low Stock:'),
            gapW8,
            Switch(
                value: ref.watch(enableLowStockProvider),
                onChanged: (value) {
                  ref.read(enableLowStockProvider.notifier).state = value;
                }),
          ],
        ),
      ]),
      gapH8,
      Visibility(
        visible: ref.watch(enableLowStockProvider),
        child: TextFormField(
          initialValue: widget.itemVariation
              .fold(() => '0', (a) => a.minimumStockCountOrNone.fold(() => '0', (a) => a.toString())),
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*'))],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minimum Stock Level*',
            hintText: 'Enter minimum stock level',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter minium stock level';
            } else if (int.tryParse(value)! <= 0) {
              return 'minium stock level must be greater than zero';
            }
            return null;
          },
          onSaved: (value) => minimumStockLevelOrNone = value == null ? const None() : optionOf(int.tryParse(value)),
        ),
      ),
      Row(
        children: [
          const Text('Enable Expiry Date:'),
          gapW8,
          Switch(
              value: ref.watch(enableExpiryDateProvider),
              onChanged: (value) {
                ref.read(enableExpiryDateProvider.notifier).state = value;
              }),
        ],
      ),
      gapH8,
      Visibility(
        visible: ref.watch(enableExpiryDateProvider),
        child: DateSelectionWidget(
            useLastDateAsToday: false,
            initialDate: widget.itemVariation.fold(() => const None(), (x) => x.expiryDate),
            onValueChanged: (value) {
              expiryDateOrNone = Some(value);
            }),
      ),
    ];
  }
}
