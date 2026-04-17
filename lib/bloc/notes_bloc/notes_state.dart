import 'package:note_app_ikokas/model/note_model.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  NotesLoaded(this.notes);
}