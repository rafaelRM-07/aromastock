import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movimiento_model.dart';
import '../repository/movimiento_repository.dart';

class MovimientoProvider extends ChangeNotifier {
  final MovimientoRepository _repository = MovimientoRepository();

  List<MovimientoModel> _movimientos = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _channel;

  List<MovimientoModel> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga todo el historial de movimientos
  Future<void> cargarHistorial() async {
    final bool wasEmpty = _movimientos.isEmpty;
    if (wasEmpty) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _movimientos = await _repository.getTodoElHistorial();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (wasEmpty) _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrega un nuevo movimiento y recarga la lista
  Future<bool> agregarMovimiento(MovimientoModel movimiento) async {
    try {
      await _repository.registrarMovimiento(movimiento);
      await cargarHistorial();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:historial_movimientos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'historial_movimientos',
          callback: (payload) async {
            final bool wasEmpty = _movimientos.isEmpty;
            if (wasEmpty) {
              _isLoading = true;
              notifyListeners();
            }

            try {
              _movimientos = await _repository.getTodoElHistorial();
            } catch (_) {
              // Ignorar errores para no romper la UI
            } finally {
              if (wasEmpty) _isLoading = false;
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
