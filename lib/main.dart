import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/firebase_options.dart';
import 'package:inventory_frontend/view/auth/custom.sign.in.screen.dart';
import 'package:inventory_frontend/view/themes/flex.theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Ideal time to initialize
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  // db.clearSync();

  // runApp(const MyApp());
  runApp(const ProviderScope(child: MyApp()));
}

final GoRouter _router = GoRouter(
  initialLocation: '/sign_in',
  routes: <RouteBase>[
    GoRoute(
      path: '/sign_in',
      builder: (BuildContext context, GoRouterState state) {
        return const CustomSignInScreen();
      },
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'billacount/create',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return CreateBillAccountScreen();
      //     },
      //   ),
      //   GoRoute(
      //     path: 'budget/create',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return AddCategoryScreen();
      //     },
      //   ),
      // ],
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
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
