import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/categoria_repository.dart';
import '../models/categoria_model.dart';

class CategoriaProvider extends ChangeNotifier {
  final _repository = CategoriaRepository();

  List<CategoriaModel> _lista = [];
  bool _cargando = false;

  RealtimeChannel? _channel;

  List<CategoriaModel> get lista => _lista;
  bool get cargando => _cargando;

  // READ
  Future<void> cargarCategorias() async {
    final bool wasEmpty = _lista.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }
    try {
      _lista = await _repository.listar();
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  // CREATE
  Future<void> crear(CategoriaModel categoria) async {
    await _repository.insertar(categoria);
    await cargarCategorias(); // refresco (será silencioso si ya hay datos)
  }

  // UPDATE
  Future<void> editar(CategoriaModel categoria) async {
    await _repository.actualizar(categoria);
    await cargarCategorias();
  }

  // DELETE
  Future<void> borrar(int id) async {
    await _repository.eliminar(id);
    await cargarCategorias();
  }

  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:categorias')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categorias',
          callback: (payload) async {
            final bool wasEmpty = _lista.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }
            try {
              _lista = await _repository.listar();
            } catch (_) {
              // Ignorar errores en actualizaciones silenciosas
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

  /// Detiene la suscripción realtime cuando la vista se desmonta
  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
