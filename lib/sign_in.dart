import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      title: "Sign in",
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: new Padding(
          padding: const EdgeInsets.all(16.0),
        ),
      ),
      providers: [
        ProvidersTypes.google,
        ProvidersTypes.email,
      ],
      avoidBottomInset: true,
      showBar: true,
    );
  }
}
