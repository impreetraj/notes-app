import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_state.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_bloc.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_event.dart';
import 'package:note_app_ikokas/core/notes_repo.dart';
import 'package:note_app_ikokas/core/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repo;
  final NotificationBloc notificationBloc;

  NotesBloc(this.repo, this.notificationBloc) : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        final notes = await repo.loadNotes(event.userId);
        emit(NotesLoaded(notes));

        repo.sync(event.userId, () {
          if (!isClosed) add(RefreshNotes(event.userId));
        });
      } catch (e, stack) {
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Failed to load notes');
        emit(NotesError(e.toString()));
      }
    });

    on<RefreshNotes>((event, emit) async {
      try {
        final notes = await repo.loadNotes(event.userId);
        emit(NotesLoaded(notes));
      } catch (e, stack) {
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Failed to refresh notes');
        emit(NotesError(e.toString()));
      }
    });

    on<AddNote>((event, emit) async {
      try {
        await repo.addNote(event.note);
        final notes = await repo.loadNotes(event.note.userId);
        emit(NoteActionSuccess("Data saved in Sqflite and Firebase", notes));

        
        await NotificationService.instance.showNotification(
          title: '📝 Note Added!',
          body: event.note.title,
        );

        
        notificationBloc.add(AddNoteNotification(
          title: '📝 Note Added!',
          body: event.note.title,
          userId: event.note.userId,
        ));

        add(RefreshNotes(event.note.userId));
      } catch (e, stack) {
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Failed to add note');
        emit(NotesError("Failed to add note: $e"));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await repo.addNote(event.note);
        final notes = await repo.loadNotes(event.note.userId);
        emit(NoteActionSuccess("Note updated", notes));
        add(RefreshNotes(event.note.userId));
      } catch (e, stack) {
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Failed to update note');
        emit(NotesError("Failed to update note: $e"));
      }
    });

    on<DeleteNote>((event, emit) async {
      try {
        await repo.deleteNote(event.id);
        final notes = await repo.loadNotes(event.userId);
        emit(NoteActionSuccess("Note deleted", notes));
        add(RefreshNotes(event.userId));
      } catch (e, stack) {
        FirebaseCrashlytics.instance
            .recordError(e, stack, reason: 'Failed to delete note');
        emit(NotesError("Failed to delete note: $e"));
      }
    });
  }
}
