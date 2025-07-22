import 'package:flutter/material.dart';
import 'session_picker_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  static String id = 'create_account_screen';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the Account Creation Screen'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.pushNamed(context, SessionPickerScreen.id);
      }),
    );
    ;
  }
}
