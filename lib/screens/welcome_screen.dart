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
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      upperBound: 1.0,
    );

    animation = ColorTween(begin: Colors.white, end: Colors.black45)
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
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
