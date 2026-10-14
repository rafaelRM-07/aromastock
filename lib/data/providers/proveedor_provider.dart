import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/proveedor_model.dart';
import '../repository/proveedor_repository.dart';

class ProveedorProvider extends ChangeNotifier {
  final _repo = ProveedorRepository();
  List<ProveedorModel> _lista = [];
  bool _cargando = false;
  RealtimeChannel? _channel;

  List<ProveedorModel> get lista => _lista;
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

  Future<void> guardar(ProveedorModel model) async {
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
        .channel('public:proveedores')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'proveedores',
          callback: (payload) async {
            final bool wasEmpty = _lista.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }
            try {
              _lista = await _repo.listar();
            } catch (_) {
              // Ignorar errores al refrescar en segundo plano
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
