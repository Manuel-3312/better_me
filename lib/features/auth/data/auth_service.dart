import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling Supabase authentication.
class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Returns the currently authenticated user, or null if not logged in.
  User? get currentUser => _client.auth.currentUser;

  /// Checks if a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Registers a new user with the provided [email] and [password].
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Authenticates an existing user with [email] and [password].
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Stream that listens to authentication state changes (e.g., login, logout).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
