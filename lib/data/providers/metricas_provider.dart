import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/metricas_model.dart';
import '../repository/metricas_repository.dart';

class MetricsProvider extends ChangeNotifier {
  final _repository = MetricsRepository();

  MetricsModel _metrics = MetricsModel.empty();
  bool _cargando = false;
  bool _hasLoaded = false;
  RealtimeChannel? _channelPedidos;
  RealtimeChannel? _channelVariantes;
  RealtimeChannel? _channelAlertas;

  MetricsModel get metrics => _metrics;
  bool get cargando => _cargando;
  bool get hasLoaded => _hasLoaded;

  // READ / FETCH
  Future<void> cargarMetricas() async {
    final bool wasEmpty = !_hasLoaded;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }

    try {
      _metrics = await _repository.obtenerMetricas();
      _hasLoaded = true;
    } catch (e) {
      debugPrint("Error al cargar métricas: $e");
    } finally {
      if (wasEmpty) {
        _cargando = false;
      }
      notifyListeners();
    }
  }

  Future<void> _refreshMetricasSilently() async {
    try {
      _metrics = await _repository.obtenerMetricas();
      _hasLoaded = true;
      notifyListeners();
    } catch (_) {
      // Ignorar errores en refresco silencioso
    }
  }

  void initRealtime() {
    if (_channelPedidos != null || _channelVariantes != null || _channelAlertas != null) return;

    _channelPedidos = Supabase.instance.client
        .channel('public:pedidos-metricas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pedidos',
          callback: (payload) async {
            await _refreshMetricasSilently();
          },
        )
        .subscribe();

    _channelVariantes = Supabase.instance.client
        .channel('public:variantes-metricas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'variantes',
          callback: (payload) async {
            await _refreshMetricasSilently();
          },
        )
        .subscribe();

    _channelAlertas = Supabase.instance.client
        .channel('public:alertas-stock-metricas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alertas_stock',
          callback: (payload) async {
            await _refreshMetricasSilently();
          },
        )
        .subscribe();
  }

  Future<void> _unsubscribeRealtime() async {
    for (final channel in [_channelPedidos, _channelVariantes, _channelAlertas]) {
      if (channel == null) continue;
      try {
        await channel.unsubscribe();
      } catch (_) {
        try {
          Supabase.instance.client.removeChannel(channel);
        } catch (_) {}
      }
    }
    _channelPedidos = null;
    _channelVariantes = null;
    _channelAlertas = null;
  }

  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
