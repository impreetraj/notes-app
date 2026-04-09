import 'package:note_app_ikokas/core/firebase_services.dart';
import 'package:note_app_ikokas/dbhelper/db_helper.dart';
import 'package:note_app_ikokas/model/note_model.dart';



class NotesRepository {
  final FirebaseService firebase;
  final LocalDbService local;

  NotesRepository(this.firebase, this.local);

  Future<List<Note>> loadNotes() async {
    return await local.getNotes(); 
  }

  Future<void> addNote(Note note) async {
    await local.insert(note);   //off
    await firebase.add(note);   // on
  }

  Future<void> deleteNote(String id) async {
    await local.delete(id);
    await firebase.delete(id);
  }

  void sync() {
    firebase.streamNotes().listen((notes) async {
      for (var n in notes) {
        await local.insert(n);
      }
    });
  }
}