
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  SignupRequested(this.name, this.email, this.password);
}

class GoogleSignInRequested extends AuthEvent {}

class MicrosoftSignInRequested extends AuthEvent {}
class FacebookSignInRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

