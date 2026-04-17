import 'package:note_app_ikokas/model/note_model.dart';

abstract class NotesEvent {}

class LoadNotes extends NotesEvent {
  final String userId;
  LoadNotes(this.userId);
}

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
  final String userId;
  DeleteNote(this.id, this.userId);
}

class RefreshNotes extends NotesEvent {
  final String userId;
  RefreshNotes(this.userId);
}
