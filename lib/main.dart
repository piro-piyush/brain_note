import 'package:brain_note/models/user_model.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:brain_note/repostiory/local_storage_repository.dart';
import 'package:brain_note/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorageRepository(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // safer for side-effects
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final res = await ref.read(authRepositoryProvider).getUser();
      if (res.data != null && res.data is UserModel) {
        final user = res.data!;
        ref.read(userProvider.notifier).setUser(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brain Note',
      debugShowCheckedModeBanner: false,
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          final user = ref.watch(userProvider);

          final isLoggedIn = user?.token.isNotEmpty ?? false;

          return isLoggedIn ? loggedInRoute : loggedOutRoute;
        },
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
