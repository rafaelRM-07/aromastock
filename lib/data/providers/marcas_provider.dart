import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/marcas_repository.dart';
import '../models/marcas_model.dart';

class MarcaProvider extends ChangeNotifier {
  final _repo = MarcaRepository();
  List<MarcaModel> _lista = [];
  bool _cargando = false;
  RealtimeChannel? _channel;

  List<MarcaModel> get lista => _lista;
  bool get cargando => _cargando;
  
  Future<void> cargarMarcas() async {
    final bool wasEmpty = _lista.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }

    try {
      _lista = await _repo.listar();
    } finally {
      if (wasEmpty) {
        _cargando = false;
      }
      notifyListeners();
    }
  }

  Future<void> guardar(MarcaModel m) async {
    m.id == null ? await _repo.insertar(m) : await _repo.actualizar(m);
    await cargarMarcas();
  }

  Future<void> borrar(int id) async {
    await _repo.eliminar(id);
    await cargarMarcas();
  }

  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:marcas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'marcas',
          callback: (payload) async {
            final bool wasEmpty = _lista.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }

            try {
              _lista = await _repo.listar();
            } catch (_) {
              // Ignorar errores en actualizaciones en segundo plano.
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
