import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'welcome_screen.dart';
import 'session_picker_screen.dart'
    show loggedInUser, isViewer, streamerName, username;

final User currentUser = loggedInUser;
final bool userIsViewer = isViewer;
final String streamer = streamerName;
final String viewer = username;

final _firestore =
    FirebaseFirestore.instance.collection('streams').doc(streamer);

List<Widget> testStream = [
  MessageBubble(
    sender: 'Flutter',
    text: 'The current user is $viewer',
    isMe: false,
    fromStreamer: false,
  ),
  MessageBubble(
    sender: 'Flutter',
    text: 'The current streamer is $streamer',
    isMe: false,
    fromStreamer: false,
  ),
  MessageBubble(
    sender: 'Sample',
    text: 'This is what I look like',
    isMe: true,
    fromStreamer: false,
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
  StreamSubscription<QuerySnapshot>? banSubscription;
  final messageTextController = TextEditingController();
  String messageText = '';

  @override
  void initState() {
    super.initState();

    if (!userIsViewer) {
      // Using regular set operation will also override an existing document completely if one exists
      _firestore.set({"isStreaming": true});
      wipeStream();
    } else {
      _firestore
          .collection('users')
          .add({'email': currentUser.email, 'username': viewer});
      banSubscription = _firestore
          .collection('banList')
          .where("email", isEqualTo: currentUser.email)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.size != 0 && context.mounted) {
          Navigator.pop(context, 4);
        }
      });
    }
    streamSubscription = _firestore.snapshots().listen((snapshot) {
      if (snapshot.data()!['isStreaming'] == false && context.mounted) {
        Navigator.pop(context, 5);
      }
    });
  }

  Future<void> wipeStream() async {
    final userSnap = await _firestore.collection('users').limit(1).get();
    if (userSnap.size != 0) {
      final batch = FirebaseFirestore.instance.batch();
      final messages = await _firestore.collection('messages').get();
      final users = await _firestore.collection('users').get();
      final bans = await _firestore.collection('banList').get();
      for (var doc in users.docs) {
        batch.delete(doc.reference);
      }
      if (messages.size != 0) {
        for (var doc in messages.docs) {
          batch.delete(doc.reference);
        }
      }
      if (bans.size != 0) {
        for (var doc in bans.docs) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    }
  }

  void leaveAsViewer(int outcome) async {
    final docRef = await _firestore
        .collection('users')
        .where("email", isEqualTo: currentUser.email)
        .get();
    for (var doc in docRef.docs) {
      await _firestore.collection('users').doc(doc.id).delete();
    }
    if (context.mounted) {
      Navigator.pop(context, outcome);
    }
  }

  @override
  void dispose() {
    messageTextController.dispose();
    streamSubscription.cancel();
    banSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150.0,
        title: Text("$streamer's Shadow Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: userIsViewer
            ? null
            : [
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
            MessagesStream(),
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
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': viewer,
                        'email': currentUser.email,
                      });
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

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: kGold,
            ),
          );
        }

        final chat = snapshot.data!.docs.reversed;
        List<MessageBubble> messages = [];
        for (var post in chat) {
          final data = post.data() as Map<String, dynamic>;
          final String message = data['text']!;
          final String sender = data['sender']!;
          final String address = data['email']!;

          messages.add(MessageBubble(
            sender: sender,
            text: message,
            isMe: address == currentUser.email,
            fromStreamer: sender == streamer,
          ));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
            children: messages,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe,
      required this.fromStreamer});

  final String sender;
  final String text;
  final bool isMe;
  final bool fromStreamer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: fromStreamer || isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: fromStreamer ? kGold : Colors.white,
            ),
          ),
          Material(
            borderRadius: fromStreamer || isMe
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
            color: !fromStreamer ? Colors.white24 : kGold,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: fromStreamer
                      ? Colors.black
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
