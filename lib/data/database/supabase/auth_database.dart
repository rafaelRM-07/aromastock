import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatabase {
  final _client = Supabase.instance.client;

  /// Inicia sesión con correo electrónico y contraseña
  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Registra un nuevo usuario con correo electrónico y contraseña
  Future<void> signOut() async {
    await _client.auth.signOut(scope: SignOutScope.global);
  }

  /// consulta el perfil del usuario por su uid
  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    return await _client.from('perfiles').select().eq('id', uid).single();
  }

  /// restablece la contraseña del usuario enviando un correo electrónico de restablecimiento
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      // Opcional: Define la URL a la que se redirigirá al usuario tras dar clic en el correo
      // Si no la pones, usará la configurada en tu Dashboard de Supabase
      // redirectTo: 'io.supabase.aromastock://reset-callback',
    );
  }
}
