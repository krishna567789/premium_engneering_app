import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:premium_engneering_app/features/auth/provider/auth_state.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider(this.repository);

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> appStarted() async {
    _setState(AuthLoading());
    try {
      final token = await repository.getToken();
      if (token != null && token.isNotEmpty) {
        _setState(AuthAuthenticated(null));
      } else {
        _setState(AuthUnauthenticated());
      }
    } catch (e) {
      _setState(AuthError(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setState(AuthLoading());
    try {
      final response = await repository.login(email: email, password: password);

      if (response.success) {
        _setState(AuthAuthenticated(response.data));
        print('LOGIN SUCCESS');
      } else if (response.statusCode == 403) {
        print('LOGIN 403');
        // Already logged in on another device
        _setState(
          AuthAlreadyLoggedIn(
            username: response.username ?? email,
            message: response.message,
          ),
        );
      } else {
        _setState(AuthError(response.message));
      }
    } catch (e) {
      _setState(AuthError(e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await repository.getToken();
      if (token != null && token.isNotEmpty) {
        _setState(AuthAuthenticated(null));
      } else {
        _setState(AuthUnauthenticated());
      }
    } catch (e) {
      _setState(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    _setState(AuthLoading());
    try {
      await repository.logout();
    } catch (e) {
      _setState(AuthError(e.toString()));
    } finally {
      // Always end up as unauthenticated locally
      _setState(AuthUnauthenticated());
    }
  }
}
