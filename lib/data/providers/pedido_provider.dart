import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido_model.dart';
import '../repository/pedido_repository.dart';

class PedidoProvider extends ChangeNotifier {
  final PedidoRepository _repository;

  PedidoProvider({PedidoRepository? repository})
    : _repository = repository ?? PedidoRepository();

  List<PedidoModel> _pedidos = [];
  bool _isLoading = false;
  String? _errorMessage;

  RealtimeChannel? _channel;

  List<PedidoModel> get pedidos => _pedidos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> cargarPedidos() async {
    final bool wasEmpty = _pedidos.isEmpty;
    if (wasEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _pedidos = await _repository.obtenerPedidos();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (wasEmpty) _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(int pedidoId, String nuevoEstado) async {
    try {
      await _repository.actualizarEstado(pedidoId, nuevoEstado);

      final index = _pedidos.indexWhere((p) => p.id == pedidoId);
      if (index != -1) {
        final actual = _pedidos[index];
        _pedidos[index] = PedidoModel(
          id: actual.id,
          usuarioId: actual.usuarioId,
          fecha: actual.fecha,
          estado: nuevoEstado,
          nombreUsuario: actual.nombreUsuario,
          detalles: actual.detalles,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:pedidos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pedidos',
          callback: (payload) async {
            final bool wasEmpty = _pedidos.isEmpty;
            if (wasEmpty) {
              _isLoading = true;
              notifyListeners();
            }
            try {
              _pedidos = await _repository.obtenerPedidos();
            } catch (_) {
              // Ignorar errores en actualizaciones silenciosas
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

  /// Detiene la suscripción cuando la vista se desmonta
  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
