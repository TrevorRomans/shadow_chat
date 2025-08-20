import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class BanScreen extends StatefulWidget {
  const BanScreen({super.key, required this.firestore});

  final DocumentReference<Map<String, dynamic>> firestore;

  @override
  State<BanScreen> createState() => _BanScreenState();
}

class _BanScreenState extends State<BanScreen> {
  String userToBan = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter a username to ban from the session. Below are the users currently banned, and entering their name will unban them',
              style: TextStyle(color: Colors.red),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: widget.firestore.collection('banList').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('There are no banned users at this time');
                }
                final users = snapshot.data!.docs;
                List<Text> bannedUsers = [];
                for (var user in users) {
                  bannedUsers.add(Text(user['lastKnownUsername']));
                }
                return Expanded(
                  child: ListView(
                    children: bannedUsers,
                  ),
                );
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      userToBan = value;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      hintText: 'Enter name here',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    bool readyToExit = false;
                    final banData = await widget.firestore
                        .collection('banList')
                        .where('lastKnownUsername', isEqualTo: userToBan)
                        .limit(1)
                        .get();
                    if (banData.size != 0) {
                      await banData.docs[0].reference.delete().then((_) {
                        if (context.mounted) {
                          readyToExit = true;
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      final userData = await widget.firestore
                          .collection('users')
                          .where('username', isEqualTo: userToBan)
                          .limit(1)
                          .get();
                      if (userData.size != 0) {
                        String email = userData.docs[0]['email']!;
                        String username = userData.docs[0]['username']!;
                        await widget.firestore.collection('banList').add({
                          'email': email,
                          'lastKnownUsername': username,
                        }).then((_) {
                          if (context.mounted) {
                            readyToExit = true;
                            Navigator.pop(context);
                          }
                        });
                      }
                    }
                    if (!readyToExit) {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog.adaptive(
                          title: Text('Action Failed'),
                          content: Text(
                              'This username does not appear to be related to this session'),
                          actions: [
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
          ],
        ),
      ),
    );
  }
}
