import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

void initMessaging() async {
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelGroupKey: 'push_notification',
        channelKey: 'normal_push',
        channelName: 'normal_notification',
        channelDescription: 'normal notification',
        defaultColor: Colors.grey,
        ledColor: Colors.blueGrey,
        enableLights: true,
        importance: NotificationImportance.Max,
        channelShowBadge: false,
        locked: false,
        playSound: true,
        defaultPrivacy: NotificationPrivacy.Public),
  ]);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    messageNotifier(message, isForeground: true);
  });
  FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);
  AwesomeNotifications()
      .setListeners(onActionReceivedMethod: onActionReceivedMethod);
}

@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction action) async {}

@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(message) async {
  messageNotifier(message);
}

@pragma("vm:entry-point")
Future<void> messageNotifier(RemoteMessage message,
    {bool isForeground = false}) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  dynamic payload = message.data;
  List<NotificationActionButton> actionButtons = getActionButtons(payload);
  if (notification != null && android != null) {
    createNotification(
        title: notification.title ?? "",
        body: notification.body ?? "",
        data: message.data,
        actionButtons: actionButtons);
  } else {
    createNotification(
      title: payload["title"] ?? "",
      body: payload["body"] ?? "",
      data: message.data,
      actionButtons: actionButtons,
    );
  }
}

List<NotificationActionButton> getActionButtons(payload) {
  List<NotificationActionButton> actionButtons = [];
  if (payload != null && payload.containsKey("converseePhoneNumber")) {
    actionButtons
        .add(NotificationActionButton(key: "chat_replay", label: "Replay"));
  } else if (payload != null && payload.containsKey("roomId")) {
    actionButtons.add(
        NotificationActionButton(key: "chat_answer_call", label: "Answer"));
  }
  return actionButtons;
}

createNotification(
    {required String title,
    required String body,
    List<NotificationActionButton> actionButtons = const [],
    dynamic data}) async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: -1, // -1 is replaced by a random number
        channelKey: 'normal_push',
        title: title,
        body: body,
        bigPicture: data?["bigPicture"],
        largeIcon: data?["largeIcon"],
        displayOnBackground: true,
        displayOnForeground: true,
        wakeUpScreen: true,
        notificationLayout: data?["bigPicture"] != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.BigText,
        payload: Map<String, String?>.from(data)),
    actionButtons: [
      ...actionButtons,
      NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
          isDangerousOption: true)
    ],
  );
}
