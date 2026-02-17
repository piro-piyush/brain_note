import 'package:brain_note/colors.dart';
import 'package:brain_note/views/login/widgets/desktop_layout_widget.dart';
import 'package:brain_note/views/login/widgets/mobile_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            if (isDesktop) {
              return DesktopLayoutWidget();
            } else {
              return MobileLayoutWidget();
            }
          },
        ),
      ),
    );
  }
}
