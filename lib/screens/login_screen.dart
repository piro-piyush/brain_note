import 'package:brain_note/colors.dart';
import 'package:brain_note/repostiory/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void onGoogleSignInTap(WidgetRef ref)async {
    try{
      final authProvider = ref.read(authRepositoryProvider);
      final googleSignInAccount = await authProvider.signIn();
      if(googleSignInAccount!=null){
        final accessToken = await authProvider.getAccessToken(googleSignInAccount);
        print(accessToken);
        print(googleSignInAccount.displayName);
        print(googleSignInAccount.email);
        print(googleSignInAccount.photoUrl);
      }
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => onGoogleSignInTap(ref),
          icon: Image.asset('assets/images/g-logo-2.png', height: 20),
          label: const Text(
            'Sign in with Google',
            style: TextStyle(color: kBlackColor),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhiteColor,
            minimumSize: const Size(150, 50),
          ),
        ),
      ),
    );
  }
}
