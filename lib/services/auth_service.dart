import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    // 'full_name' est lu par le trigger SQL handle_new_user()
    return supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<void> resetPassword(String email) {
    return supabase.auth.resetPasswordForEmail(email);
  }
}
