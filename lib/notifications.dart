import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined permission');
  }
}

void sendPushMessage(String token, String body, String title) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAM3X_bFI:APA91bFBMRZfxTi45zIc5pxsparwXFeGk61OjBaiM3g118vZGqdkBrwS23sjGPl6mSljcin07yZStwhEXWf-nY_YB12p5O0WGspXNPT4ppoJjA7kcKgSMmL5gx7unLrs4awuYGAyNuxN',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title
          },
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'android_channel_id': 'dbfood'
          },
          'to': token,
        },
      ),
    );
  } catch (e) {}
}
