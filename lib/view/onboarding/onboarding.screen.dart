import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/view/common.widgets.dart/responsive.center.dart';
import 'package:inventory_frontend/view/constants/breakpoints.dart';
import 'package:inventory_frontend/view/onboarding/currency.selection/currency.selection.wdiget.dart';
import 'package:inventory_frontend/view/onboarding/time.zone/time.zone.widget.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';
import 'package:inventory_frontend/view/teams/team.list.controller.dart';
import 'package:inventory_frontend/view/utils/alert_dialogs.dart';
import 'package:inventory_frontend/view/utils/async_value_ui.dart';
import 'package:timezone/timezone.dart' as tz;

class OnboardingScreen extends ConsumerWidget {
  OnboardingScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  Option<String> teamName = const None();
  Option<tz.Location> location = const None();
  Option<Currency> currency = const None();
  // Option<>

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      teamListControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text("Let's setup your team"),
          actions: [
            IconButton(
                onPressed: () async {
                  if (_validateAndSaveForm()) {
                    if (currency.isNone()) {
                      showAlertDialog(
                          context: context,
                          title: "Currency",
                          defaultActionText: "OK",
                          content: "Please select a currency.");
                      return;
                    }
                    if (location.isNone()) {
                      showAlertDialog(
                          context: context,
                          title: "Timezone",
                          defaultActionText: "OK",
                          content: "Please select a timezone.");
                      return;
                    }

                    final success = await ref.read(teamListControllerProvider.notifier).submit(
                        teamName: teamName.toNullable()!,
                        location: location.toIterable().first,
                        currency: currency.toIterable().first);

                    if (success && context.mounted) {
                      context.goNamed(AppRoute.dashboard.name);
                    }
                  }
                },
                icon: const Icon(Icons.check)),
          ],
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
        onSaved: (value) => teamName = optionOf(value),
      ),
      CurrencySelectionWidget(onValueChanged: (value) => currency = value),
      TimeZoneSelectionWidget(onValueChanged: (value) => location = value),
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
