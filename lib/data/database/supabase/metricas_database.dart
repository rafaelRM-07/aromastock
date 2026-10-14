import 'package:supabase_flutter/supabase_flutter.dart';

class MetricsDatabase {
  final _client = Supabase.instance.client;

  /// Obtiene los detalles de pedidos en estado 'Despachado'
  Future<List<Map<String, dynamic>>> fetchVentasDespachadas() async {
    return await _client
        .from('pedido_detalles')
        .select('cantidad, precio_unitario, pedidos!inner(estado)')
        .eq('pedidos.estado', 'Despachado');
  }

  /// Obtiene el conteo de variantes activas
  Future<List<Map<String, dynamic>>> fetchVariantesActivas() async {
    return await _client.from('variantes').select('id').eq('activo', true);
  }

  /// Obtiene las alertas de stock configuradas junto con el stock de sus variantes activas
  Future<List<Map<String, dynamic>>> fetchAlertasStock() async {
    return await _client
        .from('alertas_stock')
        .select('stock_minimo, variantes!inner(stock, activo)')
        .eq('variantes.activo', true);
  }
}
