import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shadow_chat/constants.dart';
import '../components/rounded_button.dart';
import 'chat_screen.dart';

// defined variables here can be accessed from other screens via import
late User loggedInUser;
late bool isViewer;
late String streamerName;
late String username;

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

class _SessionPickerScreenState extends State<SessionPickerScreen> {
  bool showSpinner = false;
  bool isMatching = false;
  final _auth = FirebaseAuth.instance;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    isViewer = true;
    streamerName = '';
    username = '';
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

      // Document must exist for access to be possible
      final document = await docRef.get();
      if (!document.exists) {
        return 1;
      } else {
        // If the stream session is ended but the document hasn't been fully deleted yet
        await docRef.get().then((doc) {
          if (doc.data()!['isStreaming'] == false) {
            return 1;
          }
        });

        // Attempt to retrieve banned users with a matching email address (needs to be 0)
        final data = await docRef
            .collection('banList')
            .where("email", isEqualTo: loggedInUser.email)
            .limit(1)
            .get();
        if (data.size != 0) {
          return 2;
        }

        final userData = await docRef
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
        if (userData.size != 0) {
          return 7;
        }
      }
    } else {
      // The streamer cannot use the same name as an ongoing streamer, but existing stream may have been finished
      final document = await FirebaseFirestore.instance
          .collection('streams')
          .doc(username)
          .get();
      if (document.exists && document.data()!['isStreaming'] == true) {
        return 3;
      }
    }
    return 0;
  }

  void badEnding(int reason) {
    String message = switch (reason) {
      1 =>
        'No active streamer with that name exists at this time. You may have entered a name that does not match the one being used by your streamer',
      2 ||
      4 =>
        'You have been banned from this session. You will either need to be unbanned or wait for a fresh session to rejoin',
      3 =>
        'There is already a streamer using that name, and streamer names must be unique. Either confirm your spelling or choose another name',
      5 =>
        'The streamer has just ended the session. If the streamer did not intend this, perhaps see if you can notify them of this event',
      6 =>
        'Session has successfully concluded. Begin a stream with the same username to reset the session\'s content',
      7 =>
        'Someone in this chat is using that name currently. However, this only applies to EXACT matches, so you have the option to make only a slight change to your selection to continue',
      _ =>
        'It appears that an undiagnosed error has been encountered. Feel free to try again at any time',
    };
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog.adaptive(
        title: reason == 6 ? null : Text('Unable to Access Chat Session'),
        content: Text(message),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shadow Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _auth.signOut();
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
                  setState(() {
                    if (isMatching) {
                      isMatching = false;
                    }
                    username = value;
                    if (!isViewer) {
                      streamerName = value;
                    } else if (username == streamerName) {
                      // Implied to be a viewer, the names cannot match now
                      isMatching = true;
                    }
                  });
                },
                onTapOutside: (event) {
                  // If the user taps outside the field, the keyboard will close
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: kInputTextDecoration.copyWith(
                  labelText: 'Call me...',
                  hintText: 'Enter your username',
                  errorText:
                      isMatching ? "Cannot match the streamer's name" : null,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox.adaptive(
                    value: isViewer,
                    onChanged: (value) {
                      // Switch the user type
                      // Streamer = set both names to match, viewer = clear the streamer name
                      setState(() {
                        isViewer = value!;
                        isMatching = false;
                        if (!value) {
                          streamerName = username;
                        } else {
                          streamerName = '';
                          _controller.clear();
                        }
                      });
                    },
                  ),
                  Text("I'm a viewer"),
                ],
              ),
              SizedBox(height: 20.0),
              TextField(
                // Only viewers enter their streamer's name here
                enabled: isViewer && !isMatching,
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    streamerName = value;
                    // Enforces that the viewer's name must be changed and not the streamer
                    if (username == streamerName) {
                      isMatching = true;
                    }
                  });
                },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: kInputTextDecoration.copyWith(
                    labelText: 'I will be viewing the stream of...',
                    hintText: "Enter the streamer's username"),
              ),
              SizedBox(height: 30.0),
              RoundedButton(
                title: isViewer ? 'Join Chat' : 'Create Session',
                color: kGold,
                textColor: Colors.black,
                isEnabled: streamerName != '' && username != '' && !isMatching,
                onPressed: () async {
                  int outcome = await checkForErrors();

                  // Pushes and waits for a response when exiting the next screen
                  if (outcome == 0 && context.mounted) {
                    outcome = await Navigator.pushNamed(context, ChatScreen.id)
                        as int;
                  }

                  if (outcome != 0) {
                    badEnding(outcome);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
