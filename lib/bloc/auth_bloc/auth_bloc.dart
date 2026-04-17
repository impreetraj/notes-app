
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_event.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_state.dart';
import 'package:note_app_ikokas/core/auth_repo.dart';
import 'package:note_app_ikokas/model/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepo;

  AuthBloc(this.authRepo) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      await emit.forEach(
        authRepo.user,
        onData: (firebaseUser) {
          if (firebaseUser != null) {
             return Authenticated(UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? "User",
              email: firebaseUser.email ?? "",
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
          }
          return Unauthenticated();
        },
      );
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.login(event.email, event.password);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signup(event.name, event.email, event.password);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithGoogle();
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepo.logout();
    });
  }
}
