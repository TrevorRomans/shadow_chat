import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shadow_chat/constants.dart';
import '../components/rounded_button.dart';
import 'chat_screen.dart';

class SessionPickerScreen extends StatefulWidget {
  static String id = 'session_picker_screen';

  const SessionPickerScreen({super.key});

  @override
  State<SessionPickerScreen> createState() => _SessionPickerScreenState();
}

// This is the first commit to the Session Picker Screen branch!
class _SessionPickerScreenState extends State<SessionPickerScreen> {
  bool isViewer = true;
  bool showSpinner = false;
  bool isMatching = false;
  String streamerName = '';
  String viewerName = '';

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
                color: Color(0xFFEFBF04),
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
