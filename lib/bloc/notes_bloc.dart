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
      
      
      repo.sync(() {
        if (!isClosed) add(RefreshNotes());
      });
    });

    on<RefreshNotes>((event, emit) async {
      final notes = await repo.loadNotes();
      emit(NotesLoaded(notes));
    });

    on<AddNote>((event, emit) async {
      await repo.addNote(event.note);
      add(RefreshNotes()); 
    });

    on<UpdateNote>((event, emit) async {
      await repo.addNote(event.note);
      add(RefreshNotes());
    });

    on<DeleteNote>((event, emit) async {
      await repo.deleteNote(event.id);
      add(RefreshNotes());
    });

  }
}
