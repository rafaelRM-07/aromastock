import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/variante_model.dart';
import '../repository/variantes_repository.dart';

class VarianteProvider extends ChangeNotifier {
  final _repository = VarianteRepository();

  List<VarianteModel> _variantes = [];
  bool _cargando = false;

  RealtimeChannel? _channel;

  List<VarianteModel> get variantes => _variantes;
  bool get cargando => _cargando;

  Future<void> cargarPorProducto(int productoId) async {
    final bool wasEmpty = _variantes.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }
    try {
      _variantes = await _repository.listarPorProducto(productoId);
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  // Carga todas (no siempre usada)
  Future<void> cargarTodas() async {
    final bool wasEmpty = _variantes.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }
    try {
      _variantes = await _repository.listarTodas();
    } catch (_) {}
    finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  Future<VarianteModel?> buscarPorSku(String sku) async {
    try {
      return await _repository.obtenerPorSku(sku);
    } catch (e) {
      return null;
    }
  }

  Future<bool> agregar(VarianteModel variante) async {
    try {
      await _repository.insertar(variante);
      await _refreshVariantesSilently(variante.productoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editar(VarianteModel variante) async {
    try {
      await _repository.actualizar(variante);
      await _refreshVariantesSilently(variante.productoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> eliminar(int id, int productoId) async {
    try {
      await _repository.eliminar(id);
      await _refreshVariantesSilently(productoId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _refreshVariantesSilently(int productoId) async {
    try {
      _variantes = await _repository.listarPorProducto(productoId);
      notifyListeners();
    } catch (_) {
      // Ignorar errores en refresco silencioso
    }
  }

  void initRealtime(int productoId) {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:variantes-$productoId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'variantes',
          callback: (payload) async {
            final bool wasEmpty = _variantes.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }
            try {
              _variantes = await _repository.listarPorProducto(productoId);
            } catch (_) {
              // Ignorar errores silenciosos
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

  /// Permite a la vista detener la suscripción cuando se desmonta
  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
