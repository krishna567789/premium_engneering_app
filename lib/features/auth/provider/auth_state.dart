abstract class AuthState {}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading (API calling)
class AuthLoading extends AuthState {}

/// When user is logged in
class AuthAuthenticated extends AuthState {
  final dynamic user; // Replace with your UserModel

  AuthAuthenticated(this.user);
}

/// When user is NOT logged in
class AuthUnauthenticated extends AuthState {}

/// Login Success
class LoginSuccess extends AuthState {
  final String message;

  LoginSuccess(this.message);
}

/// Signup Success
class SignupSuccess extends AuthState {
  final String message;

  SignupSuccess(this.message);
}

/// Logout Success
class LogoutSuccess extends AuthState {}

/// User is already logged in on another device (status 403)
class AuthAlreadyLoggedIn extends AuthState {
  final String username;
  final String message;

  AuthAlreadyLoggedIn({required this.username, required this.message});
}

/// Error state (common for all failures)
class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}
