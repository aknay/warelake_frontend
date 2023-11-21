import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory_frontend/view/auth/providers.dart';

//ref: https://github.com/bizz84/starter_architecture_flutter_firebase/blob/master/lib/src/features/authentication/presentation/auth_providers.dart
class CustomSignInScreen extends ConsumerWidget {
  const CustomSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProviders = ref.watch(authProvidersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: SignInScreen(
        providers: authProviders,
        // footerBuilder: (context, action) => const SignInAnonymouslyFooter(),
      ),
    );
  }
}
