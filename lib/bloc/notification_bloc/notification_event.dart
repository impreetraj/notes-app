import 'package:note_app_ikokas/model/notification_model.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  LoadNotifications({required this.userId});
}

class UpdateNotificationsList extends NotificationEvent {
  final List<NotificationModel> notifications;
  UpdateNotificationsList(this.notifications);
}

class AddNoteNotification extends NotificationEvent {
  final String title;
  final String body;
  final String userId;
  AddNoteNotification({required this.title, required this.body, required this.userId});
}


