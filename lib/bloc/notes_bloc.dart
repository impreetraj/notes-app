import 'package:note_app_ikokas/bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_state.dart';
import 'package:note_app_ikokas/core/notes_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repo;

  NotesBloc(this.repo) : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      final notes = await repo.loadNotes();
      emit(NotesLoaded(notes));
      repo.sync();
    });

    on<AddNote>((event, emit) async {
      await repo.addNote(event.note);
      add(LoadNotes());
    });
    on<UpdateNote>((event, emit) async {
      await repo.addNote(event.note);
      add(LoadNotes());
    });

    on<DeleteNote>((event, emit) async {
      await repo.deleteNote(event.id);
      add(LoadNotes());
    });
  }
}
