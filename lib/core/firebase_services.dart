import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app_ikokas/model/note_model.dart';


class FirebaseService {
  final ref = FirebaseFirestore.instance.collection('notes');

  Future<void> add(Note note) async {
    await ref.doc(note.id).set(note.toMap());
  }

  Future<void> delete(String id) async {
    await ref.doc(id).delete();
  }

  Stream<List<Note>> streamNotes() {
    return ref.snapshots().map((snapshot) =>
        snapshot.docs.map((e) => Note.fromMap(e.data())).toList());
  }
}