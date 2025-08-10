import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shadow_chat/constants.dart';
import '../components/rounded_button.dart';
import 'chat_screen.dart';

// defined variables here can be accessed from other screens via import
late User loggedInUser;
bool isViewer = true;
String streamerName = '';
String viewerName = '';

class SessionPickerScreen extends StatefulWidget {
  static String id = 'session_picker_screen';

  const SessionPickerScreen({super.key});

  @override
  State<SessionPickerScreen> createState() => _SessionPickerScreenState();
}

/*
 All error codes:
 1 = no matching streamer
 2 = banned from session
 3 = existing streamer
 4 = you were just banned
 5 = streamer has ended the session
 */

//TODO: implement Firebase user functionality
class _SessionPickerScreenState extends State<SessionPickerScreen> {
  bool showSpinner = false;
  bool isMatching = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog.adaptive(
          content: Text(
              'Something went wrong with the user data, please try again later'),
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
      Navigator.pop(context);
    }
  }

  Future<int> checkForErrors() async {
    // 1 = no matching streamer, 2 = banned from session, 3 = existing streamer
    if (isViewer) {
      final docRef =
          FirebaseFirestore.instance.collection('streams').doc(streamerName);
      final document = await docRef.get();
      if (!document.exists) {
        return 1;
      } else {
        final data = await docRef
            .collection('banList')
            .where("email", isEqualTo: loggedInUser.email)
            .get();
        if (data.size != 0) {
          return 2;
        }
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shadow Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        //TODO: change button to include signing out
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
              TextField(
                // All users enter their names here
                onChanged: (value) {
                  viewerName = value;
                },
                onTapOutside: (event) {
                  // If the user taps outside the field, the keyboard will close
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: kInputTextDecoration.copyWith(
                  labelText: 'Call me...',
                  hintText: 'Enter your username',
                  errorText:
                      isMatching ? 'Cannot match the streamer\'s name' : null,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox.adaptive(
                    value: isViewer,
                    onChanged: (value) {
                      // Reset the streamer name if box is unchecked, switch the user type
                      setState(() {
                        isViewer = value!;
                        if (!value) {
                          streamerName = '';
                        }
                      });
                    },
                  ),
                  Text('I\'m a viewer'),
                ],
              ),
              SizedBox(height: 20.0),
              TextField(
                // Only viewers enter their streamer's name here
                enabled: isViewer,
                onChanged: (value) {
                  streamerName = value;
                },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: kInputTextDecoration.copyWith(
                    labelText: 'I will be viewing the stream of...',
                    hintText: 'Enter the streamer\'s username'),
              ),
              SizedBox(height: 30.0),
              RoundedButton(
                title: isViewer ? 'Join Chat' : 'Create Session',
                color: kGold,
                textColor: Colors.black,
                onPressed: () {
                  //TODO: implement navigation logic for users

                  //TODO: if the two names match, only set the state
                  //TODO: if the document does not exist, give the appropriate warning
                  //TODO: if the document exists, but the user appears in the ban list, give the appropriate warning
                  //TODO: if everything is as it should be, navigate to the chat screen while passing important data as parameters

                  Navigator.pushNamed(context, ChatScreen.id);
                },
              ),
            ],
          ),
        ),
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
