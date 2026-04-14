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

  Future<void> sync(Function onUpdate) async {
    firebase.streamNotes().listen((firestoreNotes) async {
      
      final localNotes = await local.getNotes();
      
      
      final firestoreIds = firestoreNotes.map((e) => e.id).toSet();
      for (var localNote in localNotes) {
        if (!firestoreIds.contains(localNote.id)) {
          await local.delete(localNote.id);
        }
      }

      
      for (var n in firestoreNotes) {
        await local.insert(n);
      }

      
      onUpdate();
    });
  }
}
