import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'welcome_screen.dart';
import 'session_picker_screen.dart'
    show loggedInUser, isViewer, streamerName, viewerName;

final User currentUser = loggedInUser;
final bool userIsViewer = isViewer;
final String streamer = streamerName;
final String viewer = viewerName;

final _firestore =
    FirebaseFirestore.instance.collection('streams').doc(streamer);

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// By entering this screen, it is assumed that none of the errors from Session Picker have occurred
class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();

    if (!userIsViewer) {
      // Using regular set operation will also override an existing document completely if one exists
      _firestore.set({"isStreaming": true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the Chat Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: kIsFABEnabled
            ? () {
                Navigator.pushNamed(context, WelcomeScreen.id);
              }
            : null,
        child: kIsFABEnabled ? null : Icon(Icons.disabled_by_default),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            userIsViewer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: userIsViewer ? Colors.black12 : kGold,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: !userIsViewer
                      ? Colors.black54
                      : isMe
                          ? kGold
                          : Colors.white60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
