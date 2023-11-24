import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/common.widgets.dart/responsive.center.dart';
import 'package:inventory_frontend/view/constants/breakpoints.dart';
import 'package:inventory_frontend/view/onboarding/currency.selection/currency.selection.wdiget.dart';
import 'package:inventory_frontend/view/onboarding/time.zone/time.zone.widget.dart';

class OnboardingScreen extends ConsumerWidget {
  OnboardingScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Let's setup your team"),
        ),
        body: _buildContents());
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
      TextFormField(
        decoration: const InputDecoration(labelText: 'Team name', prefixIcon: Icon(Icons.person)),
        keyboardAppearance: Brightness.light,
        // initialValue: _name,
        validator: (value) => (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        // onSaved: (value) => _name = value,
      ),
      const CurrencySelectionWidget(),
      const TimeZoneSelectionWidget(),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Rate per hour'),
        keyboardAppearance: Brightness.light,
        // initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        // onSaved: (value) => _ratePerHour = int.tryParse(value ?? '') ?? 0,
      ),
    ];
  }
}
