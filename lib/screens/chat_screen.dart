import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/constants.dart';
import 'package:shadow_chat/screens/ban_screen.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (!userIsViewer) {
      // Using regular set operation will also override an existing document completely if one exists
      _isLoading = true;
      _firestore.set({"isStreaming": true}).then((_) {
        wipeStream().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      });
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
          leaveAsViewer(4);
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
    final messageSnap = await _firestore.collection('messages').limit(1).get();
    if (messageSnap.size != 0) {
      final batch = FirebaseFirestore.instance.batch();
      final messages = await _firestore.collection('messages').get();
      final users = await _firestore.collection('users').get();
      final bans = await _firestore.collection('banList').get();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      if (users.size != 0) {
        for (var doc in users.docs) {
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
    // Limit to 1 because only 1 match is ever possible
    final docRef = await _firestore
        .collection('users')
        .where("email", isEqualTo: currentUser.email)
        .limit(1)
        .get();
    for (var doc in docRef.docs) {
      await _firestore.collection('users').doc(doc.id).delete();
    }
    if (context.mounted) {
      Navigator.pop(context, outcome);
    }
  }

  void leaveAsStreamer(int outcome) async {
    await _firestore.update({'isStreaming': false});
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
        title: Text("$streamer's Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: userIsViewer
            ? null
            : [
                TextButton(
                  onPressed: () {
                    //TODO: add new screen for the ban function

                    //TODO: This method is just to test the stream builder, remove when finished testing
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => BanScreen(firestore: _firestore),
                        isDismissible: true);
                  },
                  child: Text('Ban a User'),
                )
              ],
        leading: IconButton(
          onPressed: () async {
            //TODO: add alert dialog
            bool? confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog.adaptive(
                title: Text('Are you sure you want to leave?'),
                content: userIsViewer
                    ? null
                    : Text(
                        'As the streamer, this will terminate the session. Any content in this session will be beyond recovery, and if a new session starts with the same name, this one will be permanently wiped'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            );
            confirmed ??= false;
            if (confirmed) {
              if (userIsViewer) {
                leaveAsViewer(0);
              } else {
                leaveAsStreamer(6);
              }
            }
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading && !userIsViewer)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: kGold,
                  ),
                ),
              )
            else
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
                      maxLines: 3,
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
                      if (messageText != '') {
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': viewer,
                          'email': currentUser.email,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        setState(() {
                          messageText = '';
                        });
                      }
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
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
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
