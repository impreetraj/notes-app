import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_bloc.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_event.dart';
import 'package:note_app_ikokas/core/notification_service.dart';
import 'package:note_app_ikokas/widgets/bottom_nav_bar.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance.init();

  final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
  final body  = message.notification?.body  ?? message.data['body']  ?? '';
  await NotificationService.instance.showNotification(title: title, body: body);
}


Future<void> initFCM() async {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('📲 FCM Token: $fcmToken');
}


class FcmListenerWrapper extends StatefulWidget {
  final String userId;
  const FcmListenerWrapper({super.key, required this.userId});

  @override
  State<FcmListenerWrapper> createState() => _FcmListenerWrapperState();
}

class _FcmListenerWrapperState extends State<FcmListenerWrapper> {
  @override
  void initState() {
    super.initState();

  
    context.read<NotificationBloc>().add(LoadNotifications(userId: widget.userId));

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
      final body  = message.notification?.body  ?? message.data['body']  ?? '';

      NotificationService.instance.showNotification(title: title, body: body);

      context.read<NotificationBloc>().add(
        AddNoteNotification(title: title, body: body, userId: widget.userId),
      );
    });

    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
      final body  = message.notification?.body  ?? message.data['body']  ?? '';
      context.read<NotificationBloc>().add(
        AddNoteNotification(title: title, body: body, userId: widget.userId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationWrapper(userId: widget.userId);
  }
}
