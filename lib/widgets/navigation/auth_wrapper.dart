import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../views/auth/auth.dart';
import '../common/loading_screen.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentSession = supabase.auth.currentSession;

    return StreamBuilder<AuthState>(
      initialData: AuthState(AuthChangeEvent.initialSession, currentSession),
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Manejo de errores de sesión
        if (snapshot.hasError) {
          final errorStr = snapshot.error.toString();
          if (errorStr.contains('refresh_token_not_found') ||
              errorStr.contains('Invalid Refresh Token')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              supabase.auth.signOut();
            });
            return const AuthView();
          }
        }

        // Obtener sesión del snapshot o directamente del cliente
        final session = snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          return const MainNavigation();
        }

        if (snapshot.connectionState == ConnectionState.waiting && currentSession == null) {
          return const LoadingScreen();
        }

        return const AuthView();
      },
    );
  }
}
