import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void requestPermission() async {
  //Request the permission to send notification to the user
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
    debugPrint('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    debugPrint('User granted provisional permission');
  } else {
    debugPrint('User declined permission');
  }
}

void sendPushMessage(String token, String body, String title) async {
  //Send a notification to a given device (token value)
  debugPrint("ok bg");
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAANLR44s4:APA91bHj8bkU9vTkXk5vY3h2gwmEhzFyjuWOi7Cd6AFMrLUivA6ziPhgegnBsKoBO85pYqsXoW9oEqY2ZKrZQfMBONYUXrRtaHyTuKYS0esEUSNPhB16Uz4oHOgMOgMUAwCDBjStODB8',
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
  } catch (e) {
    debugPrint("Notification error");
  }
}
