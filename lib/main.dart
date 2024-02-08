import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/data/shared.preferences.providers/shared.preferences.provider.dart';
import 'package:warelake/firebase_options.dart';
import 'package:warelake/view/routing/app.router.dart';
import 'package:warelake/view/themes/flex.theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Ideal time to initialize
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  tzdata.initializeTimeZones();

  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      //ref: https://riverpod.dev/docs/concepts/scopes
      // Override the unimplemented provider with the value gotten from the plugin
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Flutter Demo',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      // themeMode: ref.watch(themeModeControllerProvider),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      // home: const AuthScreen(),
    );
  }
}
