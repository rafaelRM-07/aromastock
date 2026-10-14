import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estadistica_model.dart';
import '../repository/estadisticas_repository.dart';

class EstadisticasProvider extends ChangeNotifier {
  final EstadisticasRepository _repo = EstadisticasRepository();

  bool _cargando = false;
  bool _hasLoaded = false;
  RealtimeChannel? _channelPedidos;
  RealtimeChannel? _channelMovimientos;
  RealtimeChannel? _channelVariantes;

  bool get cargando => _cargando;

  // Filtro por defecto
  String _filtroTiempo =
      'Mensual'; // Opciones: 'Semanal', 'Mensual', 'Anual', 'Todo'
  String get filtroTiempo => _filtroTiempo;

  ReporteVentasModel? _reporte;
  ReporteVentasModel? get reporte => _reporte;

  /// Cambia la temporalidad y vuelve a consultar la información
  void cambiarFiltroTiempo(String nuevoFiltro) {
    if (_filtroTiempo == nuevoFiltro) return;
    _filtroTiempo = nuevoFiltro;
    cargarEstadisticas();
  }

  /// Carga todas las estadísticas centralizadas desde el repositorio
  Future<void> cargarEstadisticas() async {
    final bool wasEmpty = !_hasLoaded;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }

    try {
      _reporte = await _repo.obtenerReporteGeneral(_filtroTiempo);
      _hasLoaded = true;
    } catch (e) {
      debugPrint('Error en EstadisticasProvider: $e');
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  Future<void> _refreshEstadisticasSilently() async {
    try {
      _reporte = await _repo.obtenerReporteGeneral(_filtroTiempo);
      _hasLoaded = true;
      notifyListeners();
    } catch (_) {
      // Ignorar errores en actualizaciones silenciosas
    }
  }

  void initRealtime() {
    if (_channelPedidos != null || _channelMovimientos != null || _channelVariantes != null) return;

    _channelPedidos = Supabase.instance.client
        .channel('public:pedidos-estadisticas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pedidos',
          callback: (payload) async {
            await _refreshEstadisticasSilently();
          },
        )
        .subscribe();

    _channelMovimientos = Supabase.instance.client
        .channel('public:historial_movimientos-estadisticas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'historial_movimientos',
          callback: (payload) async {
            await _refreshEstadisticasSilently();
          },
        )
        .subscribe();

    _channelVariantes = Supabase.instance.client
        .channel('public:variantes-estadisticas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'variantes',
          callback: (payload) async {
            await _refreshEstadisticasSilently();
          },
        )
        .subscribe();
  }

  Future<void> _unsubscribeRealtime() async {
    for (final channel in [_channelPedidos, _channelMovimientos, _channelVariantes]) {
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
    _channelMovimientos = null;
    _channelVariantes = null;
  }

  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
