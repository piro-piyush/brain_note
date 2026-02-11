import 'package:brain_note/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async{
  await GoogleSignIn.instance.initialize(
    clientId:
        '818686422862-0g0msec5o2rs5gh2lfn9aiek63dutpoj.apps.googleusercontent.com',
    serverClientId: kIsWeb
        ? null
        : '818686422862-0g0msec5o2rs5gh2lfn9aiek63dutpoj.apps.googleusercontent.com',
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Brain Note', home: const LoginScreen());
  }
}
