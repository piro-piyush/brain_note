import 'package:brain_note/colors.dart';
import 'package:brain_note/views/login/widgets/login_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopLayoutWidget extends StatelessWidget {


  const DesktopLayoutWidget({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// LEFT SIDE (Branding)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            color: kWhiteColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.edit_note_rounded, size: 60, color: kBlueColor),
                SizedBox(height: 20),
                Text(
                  "Brain Note",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  "Create, edit and collaborate on documents in real-time.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        /// RIGHT SIDE (Login)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FB),
              border: Border(left: BorderSide(color: Colors.black12)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: LoginCardWidget(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
