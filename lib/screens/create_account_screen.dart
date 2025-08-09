import 'package:flutter/material.dart';
import '../components/rounded_button.dart';
import '../constants.dart';
import 'session_picker_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountScreen extends StatefulWidget {
  static String id = 'create_account_screen';

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

// This is the first commit to the Account Creation Screen branch!
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  String email = '';
  String password = '';
  bool showSpinner = false;
  bool isValid = true;
  final _auth = FirebaseAuth.instance;

  bool looksLikeEmail(String email) {
    // Pattern: 1+ characters, an @, 1+ characters, a . and 2+ characters
    final pattern = r'^.+@.+\..{2,}$';
    final valid = RegExp(pattern);
    return valid.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      backgroundColor: Colors.black45,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/chat_logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onTap: () {
                  setState(() {
                    isValid = true;
                  });
                },
                onChanged: (value) {
                  email = value;
                },
                decoration: kInputTextDecoration.copyWith(
                  hintText: 'Enter your email',
                  errorText: isValid ? null : 'Please enter a valid email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kInputTextDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Create Account',
                color: Colors.teal,
                onPressed: () async {
                  if (looksLikeEmail(email)) {
                    setState(() {
                      showSpinner = true;
                    });
                    //TODO: attempt to create user
                    try {
                      final newUser = _auth.createUserWithEmailAndPassword(
                          email: email, password: password);
                      Navigator.pushNamed(context, SessionPickerScreen.id);
                    } on FirebaseAuthException catch (e) {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog.adaptive(
                          title: Text('Failed to Create Account'),
                          content: Text(e.message!),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } else {
                    setState(() {
                      isValid = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: kIsFABEnabled
            ? () {
                Navigator.pushNamed(context, SessionPickerScreen.id);
              }
            : null,
        child: kIsFABEnabled ? null : Icon(Icons.disabled_by_default),
      ),
    );
  }
}
