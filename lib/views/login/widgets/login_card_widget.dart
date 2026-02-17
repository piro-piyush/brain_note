import 'package:brain_note/colors.dart';
import 'package:brain_note/common/utils/popups_utils.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginCardWidget extends ConsumerStatefulWidget {
  const LoginCardWidget({super.key});

  @override
  ConsumerState<LoginCardWidget> createState() => _LoginCardWidgetState();
}

class _LoginCardWidgetState extends ConsumerState<LoginCardWidget> {
  bool isLoading = false;

  Future<void> _handleMobileSignIn(BuildContext context) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.signIn();

      if (!context.mounted) return;

      /// ❌ Error
      if (result.error != null) {
        PopupUtils.showSnackBar(
          context,
          result.error ?? "Something went wrong",
          isError: true,
        );
        return;
      }

      /// ✅ Success
      final user = result.data!;
      ref.read(userProvider.notifier).set(user);

      PopupUtils.showSnackBar(context, "Welcome ${user.email}");

      Routemaster.of(context).replace('/');
    } catch (e, stack) {
      debugPrint("Login Error: $e");
      debugPrintStack(stackTrace: stack);

      if (context.mounted) {
        PopupUtils.showSnackBar(
          context,
          "Network error. Please try again.",
          isError: true,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome back",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in to continue to Brain Note.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handleMobileSignIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kWhiteColor,
              elevation: 2,
              disabledBackgroundColor: kWhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(kBlueColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/g-logo-2.png', height: 22),
                      const SizedBox(width: 12),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kBlackColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
