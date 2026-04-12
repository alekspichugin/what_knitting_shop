abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}
