import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/auth_repository.dart';
import '../models/perfil_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  PerfilModel? _perfil;
  bool _cargando = false;

  PerfilModel? get perfil => _perfil;
  bool get cargando => _cargando;

  AuthProvider() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _perfil = null;
        notifyListeners();
      }
    });
  }

  Future<void> cargarPerfil() async {
    if (_perfil != null) return;
    _cargando = true;
    notifyListeners();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) _perfil = await _repo.obtenerPerfil(user.id);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _cargando = true;
    notifyListeners();
    try {
      _perfil = await _repo.iniciarSesion(email, password);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _cargando = true;
    notifyListeners();
    try {
      await _repo.cerrarSesion();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _cargando = true;
    notifyListeners();
    try {
      await _repo.enviarEmailRecuperacion(email);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
