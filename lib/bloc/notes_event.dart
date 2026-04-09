import 'package:note_app_ikokas/model/note_model.dart';

abstract class NotesEvent {}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final Note note;
  AddNote(this.note);
}
class UpdateNote extends NotesEvent {
  final Note note;
  UpdateNote(this.note);
}

class DeleteNote extends NotesEvent {
  final String id;
  DeleteNote(this.id);
}