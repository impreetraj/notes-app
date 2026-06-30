import 'package:note_app_ikokas/model/note_model.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  NotesLoaded(this.notes);
}

class NoteActionSuccess extends NotesState {
  final String message;
  final List<Note> notes;
  NoteActionSuccess(this.message, this.notes);
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}