import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'welcome_screen.dart';
import 'session_picker_screen.dart'
    show loggedInUser, isViewer, streamerName, username;

//TODO: revert to normal form after Firestore is up and running
final User? currentUser = kIsFABEnabled ? null : loggedInUser;
final bool userIsViewer = kIsFABEnabled ? true : isViewer;
final String streamer = kIsFABEnabled ? 'TheWraith' : streamerName;
final String viewer = kIsFABEnabled ? 'Sample' : username;

final _firestore =
    FirebaseFirestore.instance.collection('streams').doc(streamer);

List<Widget> testStream = [
  MessageBubble(
    sender: 'Flutter',
    text: 'The current user is $viewer',
    isMe: false,
  ),
  MessageBubble(
    sender: 'Flutter',
    text: 'The current streamer is $streamer',
    isMe: false,
  ),
  MessageBubble(
    sender: 'Sample',
    text: 'This is what I look like',
    isMe: true,
  ),
  Padding(
    padding: EdgeInsets.all(10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          streamer,
          style: TextStyle(
            fontSize: 12.0,
            color: kGold,
          ),
        ),
        Material(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          elevation: 5.0,
          color: kGold,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Text(
              'This is what the streamer looks like',
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
];

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// By entering this screen, it is assumed that none of the errors from Session Picker have occurred
class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<DocumentSnapshot> streamSubscription;
  final messageTextController = TextEditingController();
  String messageText = '';

  @override
  void initState() {
    super.initState();

    if (!userIsViewer) {
      // Using regular set operation will also override an existing document completely if one exists
      _firestore.set({"isStreaming": true});
    }
    streamSubscription = _firestore.snapshots().listen((snapshot) {
      if (snapshot.data()!['isStreaming'] == false && context.mounted) {
        Navigator.pop(context, 5);
      }
    });
  }

  @override
  void dispose() {
    messageTextController.dispose();
    streamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$streamer's Shadow Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: /*userIsViewer
                ? null
                : */
            [
          TextButton(
            onPressed: () {
              //TODO: add new screen for the ban function

              //TODO: This method is just to test the stream builder, remove when finished testing
              _firestore.update({'isStreaming': false});
            },
            child: Text('Ban a User'),
          )
        ],
        leading: TextButton.icon(
          onPressed: () {
            //TODO: add alert dialog before exiting
            Navigator.pop(context, 0);
          },
          icon: Icon(Icons.arrow_back_outlined),
          label: Text(userIsViewer ? 'Leave Chat' : 'End Session'),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
                children: testStream.reversed.toList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: kGold, width: 2.0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      //TODO: add message to firestore
                    },
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: kGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        crossAxisAlignment: !userIsViewer || isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: !userIsViewer ? kGold : Colors.white,
            ),
          ),
          Material(
            borderRadius: !userIsViewer || isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: userIsViewer ? Colors.white24 : kGold,
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
