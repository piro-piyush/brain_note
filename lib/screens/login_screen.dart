import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:brain_note/common/widgets/buttons/google_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _handleMobileSignIn(WidgetRef ref) async {
    try {
      final repo = ref.read(authRepositoryProvider);

      final account = await repo.signIn();

      if (account == null) return;

      final token = await repo.getAccessToken(account);

      debugPrint("✅ Token: $token");
      debugPrint("User: ${account.email}");
    } catch (e) {
      debugPrint("❌ SignIn error: $e");
    }
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
                onPressed: () => _handleMobileSignIn(ref),
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
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
      ),
    );
  }
}
