import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alertas_model.dart';
import '../repository/alerta_repository.dart';

class AlertaProvider extends ChangeNotifier {
  final AlertaRepository _repository = AlertaRepository();

  List<AlertaStockModel> _alertas = [];
  bool _isLoading = false;
  String? _errorMessage;

  RealtimeChannel? _channel;

  List<AlertaStockModel> get alertas => _alertas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga las alertas desde la base de datos Supabase
  Future<void> cargarAlertas() async {
    final bool wasEmpty = _alertas.isEmpty;
    if (wasEmpty) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _alertas = await _repository.obtenerAlertas();
    } catch (e) {
      _errorMessage = 'Error al cargar las alertas de inventario.';
      debugPrint('Error en cargarAlertas: $e');
    } finally {
      if (wasEmpty) _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajusta el stock (+1 o -1) con actualización optimista e inmediata en la interfaz
  Future<void> modificarStock(AlertaStockModel alerta, int cambio) async {
    final nuevoStock = alerta.stockActual + cambio;
    if (nuevoStock < 0) return; // Evita stock negativo

    final stockAnterior = alerta.stockActual;

    // 1. Actualización inmediata en UI
    alerta.stockActual = nuevoStock;
    notifyListeners();

    // 2. Persistencia en Supabase
    final exito = await _repository.actualizarStock(
      alerta.varianteId,
      nuevoStock,
    );

    // 3. Si falla la red, revierte al valor original
    if (!exito) {
      alerta.stockActual = stockAnterior;
      notifyListeners();
    }
  }

  /// Inicia la suscripción realtime para alertas
  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:alertas_stock')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alertas_stock',
          callback: (payload) async {
            final bool wasEmpty = _alertas.isEmpty;
            if (wasEmpty) {
              _isLoading = true;
              notifyListeners();
            }
            try {
              _alertas = await _repository.obtenerAlertas();
            } catch (_) {
              // Ignorar errores de actualización silenciosa
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

  /// Detiene la suscripción desde la vista si se requiere
  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
