import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_event.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_state.dart';
import 'package:note_app_ikokas/core/auth_repo.dart';
import 'package:note_app_ikokas/model/user_model.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


class _InternalAuthChanged extends AuthEvent {
  final User user;
  _InternalAuthChanged(this.user);
}

class _InternalAuthLogout extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepo;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc(this.authRepo) : super(AuthInitial()) {
    
    _userSubscription = authRepo.user.listen((firebaseUser) {
      if (firebaseUser != null) {
        add(_InternalAuthChanged(firebaseUser));
      } else {
        add(_InternalAuthLogout());
      }
    });

    
    on<_InternalAuthChanged>((event, emit) {
      emit(Authenticated(UserModel(
        uid: event.user.uid,
        name: event.user.displayName ?? "User",
        email: event.user.email ?? "",
        createdAt: DateTime.now().millisecondsSinceEpoch,
      )));
    });

    on<_InternalAuthLogout>((event, emit) {
      if (state is! AuthLoading) {
        emit(Unauthenticated());
      }
    });

    
    on<AuthCheckRequested>((event, emit) {
      
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.login(event.email, event.password);
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Email login failed');
        emit(AuthError(e.toString()));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signup(event.name, event.email, event.password);
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Email signup failed');
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithGoogle();
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Google sign-in failed');
        emit(AuthError(e.toString()));
      }
    });

    on<MicrosoftSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithMicrosoft();
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Microsoft sign-in failed');
        emit(AuthError(e.toString()));
      }
    });

    on<FacebookSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithFacebook();
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Facebook sign-in failed');
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepo.logout();
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}


