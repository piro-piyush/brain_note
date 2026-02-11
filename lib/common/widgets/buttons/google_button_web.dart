import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart';

Widget buildGoogleButton() {
  return renderButton(
    configuration: GSIButtonConfiguration(
      theme: GSIButtonTheme.outline, // white + border
      size: GSIButtonSize.large,
      text: GSIButtonText.signinWith,
      shape: GSIButtonShape.rectangular,
     minimumWidth:   220,
    ),
  );
}
