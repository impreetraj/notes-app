import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:note_app_ikokas/model/notification_model.dart';

class FirebaseService {
  final ref = FirebaseFirestore.instance.collection('notes');

  Future<void> add(Note note) async {
    await ref.doc(note.id).set(note.toMap());

    print("data save in firebase");
  }

  Future<void> delete(String id) async {
    await ref.doc(id).delete();
  }

  Stream<List<Note>> streamNotes(String userId) {
    return ref.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) => snapshot.docs.map((e) => Note.fromMap(e.data())).toList(),
    );
  }

  // --- Notifications ---
  final notifRef = FirebaseFirestore.instance.collection('notifications');

  Future<void> addNotification(NotificationModel notif) async {
    await notifRef.doc(notif.id).set(notif.toMap());
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return notifRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((e) => NotificationModel.fromMap(e.data()))
          .toList();
      // Sort locally to avoid needing a Firebase Composite Index
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> clearNotifications(String userId) async {
    final docs = await notifRef.where('userId', isEqualTo: userId).get();
    for (var doc in docs.docs) {
      await doc.reference.delete();
    }
  }
}
