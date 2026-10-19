import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_client.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// Affiche l'écran de connexion ou l'accueil selon l'état de la session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        return session != null ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
