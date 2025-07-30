import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// This is my first commit to the Welcome Screen branch!
class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the Welcome Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: kIsFABEnabled
            ? () {
                Navigator.pushNamed(context, LoginScreen.id);
              }
            : null,
        child: kIsFABEnabled ? null : Icon(Icons.disabled_by_default),
      ),
    );
  }
}
