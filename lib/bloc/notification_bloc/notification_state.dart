import 'package:note_app_ikokas/model/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  const NotificationState({this.notifications = const []});

  NotificationState copyWith({List<NotificationModel>? notifications}) =>
      NotificationState(notifications: notifications ?? this.notifications);
}
