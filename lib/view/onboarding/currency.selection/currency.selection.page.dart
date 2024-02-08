
import 'package:flutter/material.dart';
import 'package:warelake/data/currency.code/valueobject.dart';

class CurrencySelectionPage extends StatefulWidget {
  const CurrencySelectionPage({super.key});

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select a currency")),
        body: ListView.builder(
          itemCount: CurrencyNameMap.currencyCodeAndNameUiModelList.length,
          itemBuilder: (context, index) {
            final item = CurrencyNameMap.currencyCodeAndNameUiModelList[index];

            return ListTile(
              onTap: () {
                Navigator.pop(context, CurrencyNameMap.currencyCodeAndNameUiModelList[index]);
              },
              title: Text("${item.name} (${item.code})"),
            );
          },
        ),
      ),
    );
  }
}
