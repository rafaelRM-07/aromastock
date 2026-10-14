import '../database/supabase/metricas_database.dart';
import '../models/metricas_model.dart';

class MetricsRepository {
  final _db = MetricsDatabase();

  Future<MetricsModel> obtenerMetricas() async {
    // 1. Obtener Ventas Despachadas y calcular total ($)
    final ventasData = await _db.fetchVentasDespachadas();
    double ventaTotal = 0.0;
    for (var item in ventasData) {
      final cantidad = (item['cantidad'] as num?)?.toInt() ?? 0;
      final precio = (item['precio_unitario'] as num?)?.toDouble() ?? 0.0;
      ventaTotal += (cantidad * precio);
    }

    // 2. Obtener Perfumes (variantes) Activos
    final variantesData = await _db.fetchVariantesActivas();
    int perfumesActivos = variantesData.length;

    // 3. Obtener Alertas con stock bajo (stock_actual <= stock_minimo)
    final alertasData = await _db.fetchAlertasStock();
    int alertasStockBajo = 0;
    for (var item in alertasData) {
      final stockMinimo = (item['stock_minimo'] as num?)?.toInt() ?? 5;
      final stockActual = (item['variantes']['stock'] as num?)?.toInt() ?? 0;
      if (stockActual <= stockMinimo) {
        alertasStockBajo++;
      }
    }

    return MetricsModel(
      ventaTotal: ventaTotal,
      perfumesActivos: perfumesActivos,
      alertasStockBajo: alertasStockBajo,
    );
  }
}
