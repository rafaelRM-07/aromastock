import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/familia_olfativa_repository.dart';
import '../models/familia_olfativa_model.dart';

class FamiliaOlfativaProvider extends ChangeNotifier {
  final _repo = FamiliaOlfativaRepository();
  List<FamiliaOlfativaModel> _lista = [];
  bool _cargando = false;
  RealtimeChannel? _channel;

  List<FamiliaOlfativaModel> get lista => _lista;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    final bool wasEmpty = _lista.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }

    try {
      _lista = await _repo.listar();
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  Future<void> guardar(FamiliaOlfativaModel model) async {
    if (model.id == null) {
      await _repo.insertar(model);
    } else {
      await _repo.actualizar(model);
    }
    await cargar();
  }

  Future<void> borrar(int id) async {
    await _repo.eliminar(id);
    await cargar();
  }

  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:familias_olfativas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'familias_olfativas',
          callback: (payload) async {
            final bool wasEmpty = _lista.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }
            try {
              _lista = await _repo.listar();
            } catch (_) {
              // Ignorar errores de actualización silenciosa
            } finally {
              if (wasEmpty) _cargando = false;
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  Future<void> _unsubscribeRealtime() async {
    if (_channel == null) return;
    try {
      await _channel!.unsubscribe();
    } catch (_) {
      try {
        Supabase.instance.client.removeChannel(_channel!);
      } catch (_) {}
    }
    _channel = null;
  }

  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
