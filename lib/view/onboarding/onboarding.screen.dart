import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/data/onboarding/onboarding.repository.dart';
import 'package:inventory_frontend/view/common.widgets.dart/responsive.center.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(onboardingRepositoryProvider);


    return Scaffold(body: ResponsiveCenter(child: Text("Onboarding")));
  }
}
