import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'chat_screen.dart';

class SessionPickerScreen extends StatefulWidget {
  static String id = 'session_picker_screen';

  const SessionPickerScreen({super.key});

  @override
  State<SessionPickerScreen> createState() => _SessionPickerScreenState();
}

// This is the first commit to the Session Picker Screen branch!
class _SessionPickerScreenState extends State<SessionPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the Session Picker Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: kIsFABEnabled
            ? () {
                Navigator.pushNamed(context, ChatScreen.id);
              }
            : null,
        child: kIsFABEnabled ? null : Icon(Icons.disabled_by_default),
      ),
    );
  }
}
