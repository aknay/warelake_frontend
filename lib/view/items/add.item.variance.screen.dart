import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/view/common.widgets/responsive.center.dart';
import 'package:warelake/view/constants/app.sizes.dart';
import 'package:warelake/view/constants/breakpoints.dart';
import 'package:warelake/view/utils/currency.input.formatter.dart';

class AddItemVariationScreen extends ConsumerStatefulWidget {
  const AddItemVariationScreen({super.key, this.itemVariation, this.hideStockLevelUi});
  final ItemVariation? itemVariation;
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
  Option<int> currentStockLevel = const Some(0);
  Option<int> reorderStockLevel = const Some(0);
  late final CurrencyCode currencyCode;
  late final currencyFormatter = CurrencyTextInputFormatter(currencyCode: currencyCode);
  late final bool hideStockLevelUi = widget.hideStockLevelUi == null ? false : widget.hideStockLevelUi!;

  @override
  void initState() {
    super.initState();

    final currencyCodeOrNone = ref.read(teamIdSharedReferenceRepositoryProvider).currencyCode;
    currencyCode = currencyCodeOrNone.toNullable()!;
    if (widget.itemVariation != null) {
      final itemVariation = widget.itemVariation!;
      itemVariationName = Some(itemVariation.name);
    }
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
        log("sale price money ${salePriceMoney.amount}");
        log("purchase price money ${purchasePriceMoney.amount}");


        final itemCount = currentStockLevel.fold(() => 0, (a) => a);

        if (widget.itemVariation == null) {
          final itemVariation = ItemVariation.create(
              name: itemVariationName.fold(() => '', (a) => a),
              stockable: true,
              sku: 'abc',
              salePriceMoney: salePriceMoney,
              purchasePriceMoney: purchasePriceMoney,
              itemCount: itemCount,
              barcode: barcodeOrNone.toNullable());

          context.pop(itemVariation);
        } else {

          final itemVariation = widget.itemVariation!.copyWith(
              name: itemVariationName.fold(() => '', (a) => a),
              stockable: true,
              sku: 'abc',
              salePriceMoney: salePriceMoney,
              purchasePriceMoney: purchasePriceMoney,
              itemCount: itemCount,
              barcode: barcodeOrNone.fold(() => '', (a) => a));

          context.pop(itemVariation);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemVariation == null ? 'New Item' : 'Edit Item'),
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

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        initialValue: widget.itemVariation?.name,
        decoration: const InputDecoration(
          labelText: 'Item Name *',
          hintText: 'Enter your username',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
        onSaved: (value) => itemVariationName = optionOf(value),
      ),
      Column(children: [
        gapH8,
        TextFormField(
          initialValue: widget.itemVariation?.salePriceMoney.amountInDouble.toString(),
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
          initialValue: widget.itemVariation?.purchasePriceMoney.amountInDouble.toString(),
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
        TextFormField(
          initialValue: widget.itemVariation?.barcode,
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
      ]),
    ];
  }
}
