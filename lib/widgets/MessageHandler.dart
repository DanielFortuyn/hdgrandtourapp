import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  // final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _handleMessages(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('FCM Push Notifications'),
      ),
    );
  }

  // /// Get the token, save it to the database for current user
  // _saveDeviceToken() async {
  //   // Get the current user
  //   String uid = 'jeffd23';
  //   // FirebaseUser user = await _auth.currentUser();

  //   // Get the token for this device
  //   String fcmToken = await _fcm.getToken();

  //   // Save it to Firestore
  //   if (fcmToken != null) {
  //     var tokens = _db
  //         .collection('users')
  //         .document(uid)
  //         .collection('tokens')
  //         .document(fcmToken);

  //     await tokens.setData({
  //       'token': fcmToken,
  //       'createdAt': FieldValue.serverTimestamp(), // optional
  //       'platform': Platform.operatingSystem // optional
  //     });
  //   }
  // }

  /// Subscribe the user to a topic
  // _subscribeToTopic() async {
  //   // Subscribe the user to a topic
  //   _fcm.subscribeToTopic('puppies');
  // }
}
