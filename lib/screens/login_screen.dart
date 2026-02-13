import 'package:brain_note/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:brain_note/common/widgets/buttons/google_button.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _handleMobileSignIn(WidgetRef ref, BuildContext context) async {
    final repo = ref.read(authRepositoryProvider);

    final result = await repo.signIn();

    /// ❌ ERROR
    if (result.error != null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error ?? 'Login failed')));
      return;
    }

    /// ✅ SUCCESS
    final user = result.data!;

    /// 🔹 update state
    ref.read(userProvider.notifier).setUser(user);

    if (!context.mounted) return;

    /// 🔹 snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("✅ User: ${user.email}")));

    /// 🔹 navigate
    final navigator = Routemaster.of(context);
    navigator.replace('/');
    debugPrint("✅ User: ${user.email}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: kIsWeb
            /// 🌍 WEB → Google official button
            ? buildGoogleButton()
            /// 📱 MOBILE → normal authenticate()
            : ElevatedButton.icon(
                onPressed: () => _handleMobileSignIn(ref, context),
                icon: Image.asset('assets/images/g-logo-2.png', height: 20),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(220, 50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
      ),
    );
  }
}
