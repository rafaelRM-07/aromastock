import '../database/supabase/auth_database.dart';
import '../models/perfil_model.dart';

class AuthRepository {
  final AuthDatabase _db = AuthDatabase();

  Future<PerfilModel> iniciarSesion(String email, String password) async {
    final res = await _db.login(email, password);
    if (res.user == null) throw Exception("Error de autenticación");

    final data = await _db.fetchProfile(res.user!.id);
    return PerfilModel.fromJson(data);
  }

  Future<PerfilModel> obtenerPerfil(String userId) async {
    final data = await _db.fetchProfile(userId);
    return PerfilModel.fromJson(data);
  }

  Future<void> cerrarSesion() async {
    await _db.signOut();
  }

  // En tu archivo auth_repository.dart
  Future<void> enviarEmailRecuperacion(String email) async {
    // Aquí debe coincidir con el nombre exacto de la función en AuthDatabase
    await _db.sendPasswordResetEmail(email);
  }
}
