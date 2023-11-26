import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/bill.account/valueobject.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/common.widgets.dart/responsive.center.dart';
import 'package:inventory_frontend/view/constants/breakpoints.dart';
import 'package:inventory_frontend/view/utils/currency.input.formatter.dart';

class AddItemVariationScreen extends ConsumerStatefulWidget {
  const AddItemVariationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemVariationScreenState();
}

class _AddItemVariationScreenState extends ConsumerState<AddItemVariationScreen> {
  final _formKey = GlobalKey<FormState>();
  Option<String> itemVariationName = const None();
  Option<String> itemVariationUnit = const None();
  Option<double> purchasingPrice = const None();
  Option<double> sellingPrice = const None();
  Option<int> currentStockLevel = const Some(0);
  Option<int> reorderStockLevel = const Some(0);
  final currencyCode = CurrencyCode.AED;
  late final currencyFormatter = CurrencyTextInputFormatter(currencyCode: currencyCode);

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
      if (itemVariationName.isSome() &&
          itemVariationUnit.isSome() &&
          purchasingPrice.isSome() &&
          sellingPrice.isSome()) {
        final salePrice = sellingPrice.fold(() => 0.0, (a) => a);
        final salePriceMoney = PriceMoney(amount: (salePrice * 1000).toInt(), currency: currencyCode.name);

        final purchasePrice = purchasingPrice.fold(() => 0.0, (a) => a);
        final purchasePriceMoney = PriceMoney(amount: (purchasePrice * 1000).toInt(), currency: currencyCode.name);

        final itemVariation = ItemVariation.create(
            name: itemVariationName.fold(() => '', (a) => a),
            stockable: true,
            sku: 'abc',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);

        context.pop(itemVariation);
      }

      // final success =
      //     await ref.read(editJobScreenControllerProvider.notifier).submit(
      //           jobId: widget.jobId,
      //           oldJob: widget.job,
      //           name: _name ?? '',
      //           ratePerHour: _ratePerHour ?? 0,
      //         );
      // if (success && mounted) {
      //   context.pop();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.job == null ? 'New Job' : 'Edit Job'),
        title: const Text('Item Variation'),
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
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
      // TextFormField(
      //   decoration: const InputDecoration(labelText: 'Job name'),
      //   keyboardAppearance: Brightness.light,
      //   // initialValue: _name,
      //   validator: (value) =>
      //       (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
      //   onSaved: (value) => _name = value,
      // ),
      // TextFormField(
      //   decoration: const InputDecoration(labelText: 'Rate per hour'),
      //   keyboardAppearance: Brightness.light,
      //   initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
      //   keyboardType: const TextInputType.numberWithOptions(
      //     signed: false,
      //     decimal: false,
      //   ),
      //   onSaved: (value) => _ratePerHour = int.tryParse(value ?? '') ?? 0,
      // ),

      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Item Variation Name *',
          hintText: 'Enter your username',
          suffixIcon: Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
        onSaved: (value) => itemVariationName = optionOf(value),
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Unit *',
          hintText: 'Enter your username',
          suffixIcon: Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
            onSaved: (value) => itemVariationUnit = optionOf(value),
      ),
      Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Text("Sales Information"),
            TextFormField(
              inputFormatters: <TextInputFormatter>[currencyFormatter],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Purchase Price*',
                hintText: 'Enter your username',
                suffixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
                   onSaved: (value) =>
                  purchasingPrice = value == null ? optionOf(double.tryParse(value ?? '')) : const Some(0),
            ),
            const SizedBox(height: 8),
            TextFormField(
              inputFormatters: <TextInputFormatter>[currencyFormatter],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Selling Price *',
                hintText: 'Enter your username',
                suffixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
                  onSaved: (value) =>
                  sellingPrice = value == null ? optionOf(double.tryParse(value ?? '')) : const Some(0),
            ),
          ]),
        ),
      ),
      Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Text("Inventory Information"),
            TextFormField(
              initialValue: currentStockLevel.fold(() => null, (a) => '$a'),
              decoration: const InputDecoration(
                labelText: 'Current Stock Level',
                hintText: 'Enter your username',
                suffixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: reorderStockLevel.fold(() => null, (a) => '$a'),
              decoration: const InputDecoration(
                labelText: 'Reorder Stock Level',
                hintText: 'Enter your username',
                suffixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              onSaved: (value) =>
                  reorderStockLevel = value == null ? optionOf(int.tryParse(value ?? '')) : const Some(0),
            ),
          ]),
        ),
      )
    ];
  }
}

class AddItemVariationScreenf extends ConsumerWidget {
  AddItemVariationScreenf({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Option<String> itemVariationName = const None();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.goNamed(AppRoute.addItem.name);
      //   },
      //   child: const Icon(Icons.add),
      // ),
      appBar: AppBar(
        title: const Text("Add Item Variation"),
        actions: [
          IconButton(
              onPressed: () async {
                // if (_validateAndSaveForm()) {
                //   if (currency.isNone()) {
                //     showAlertDialog(
                //         context: context,
                //         title: "Currency",
                //         defaultActionText: "OK",
                //         content: "Please select a currency.");
                //     return;
                //   }
                //   if (location.isNone()) {
                //     showAlertDialog(
                //         context: context,
                //         title: "Timezone",
                //         defaultActionText: "OK",
                //         content: "Please select a timezone.");
                //     return;
                //   }

                //   final success = await ref.read(teamListControllerProvider.notifier).submit(
                //       teamName: teamName.toNullable()!,
                //       location: location.toIterable().first,
                //       currency: currency.toIterable().first);

                //   if (success && context.mounted) {
                //     context.goNamed(AppRoute.dashboard.name);
                //   }
                // }
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
          // child: _buildForm(),
          child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Item Variation Name *',
              hintText: 'Enter your username',
              suffixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Unit *',
              hintText: 'Enter your username',
              suffixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                const Text("Sales Information"),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Price*',
                    hintText: 'Enter your username',
                    suffixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                    hintText: 'Enter your username',
                    suffixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ]),
            ),
          ),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                const Text("Inventory Information"),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Current Stock Level',
                    hintText: 'Enter your username',
                    suffixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Reorder Stock Level',
                    hintText: 'Enter your username',
                    suffixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ]),
            ),
          )
        ],
      )),
      // )
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

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Team name', prefixIcon: Icon(Icons.person)),
        keyboardAppearance: Brightness.light,
        // initialValue: _name,
        validator: (value) => (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => itemVariationName = optionOf(value),
      ),
      // CurrencySelectionWidget(onValueChanged: (value) => currency = value),
      // TimeZoneSelectionWidget(onValueChanged: (value) => location = value),
      // TextFormField(
      //   decoration: const InputDecoration(labelText: 'Rate per hour'),
      //   keyboardAppearance: Brightness.light,
      //   // initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
      //   keyboardType: const TextInputType.numberWithOptions(
      //     signed: false,
      //     decimal: false,
      //   ),
      //   // onSaved: (value) => _ratePerHour = int.tryParse(value ?? '') ?? 0,
      // ),
    ];
  }
}
