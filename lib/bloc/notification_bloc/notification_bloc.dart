import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_event.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_state.dart';
import 'package:note_app_ikokas/model/notification_model.dart';
import 'package:note_app_ikokas/core/firebase_services.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseService firebaseService;
  StreamSubscription? _subscription;

  NotificationBloc({required this.firebaseService}) : super(const NotificationState()) {
    on<LoadNotifications>((event, emit) {
      _subscription?.cancel();
      _subscription = firebaseService.streamNotifications(event.userId).listen((notifications) {
        add(UpdateNotificationsList(notifications));
      });
    });

    on<UpdateNotificationsList>((event, emit) {
      emit(state.copyWith(notifications: event.notifications));

    });

    on<AddNoteNotification>((event, emit) async {
      final newItem = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        body: event.body,
        timestamp: DateTime.now(),
        userId: event.userId,
      );
      await firebaseService.addNotification(newItem);
    });

 
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
