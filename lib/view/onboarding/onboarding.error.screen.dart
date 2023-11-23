import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingErrorScreen extends ConsumerWidget {
  const OnboardingErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unable to connnect right now.'),
              Text('Please try again later.'),
            ],
          ),
        ));
  }
}
