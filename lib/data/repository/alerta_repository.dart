import '../database/supabase/alertas_database.dart';
import '../models/alertas_model.dart';

class AlertaRepository {
  final AlertasDatabase _database = AlertasDatabase();

  /// Trae la lista de alertas parseada a modelos de Dart
  Future<List<AlertaStockModel>> obtenerAlertas() async {
    final rawData = await _database.getAlertasStock();
    return rawData.map((item) => AlertaStockModel.fromMap(item)).toList();
  }

  /// Actualiza el stock de la variante asociada a la alerta
  Future<bool> actualizarStock(int varianteId, int nuevoStock) async {
    try {
      await _database.updateStockVariante(varianteId, nuevoStock);
      return true;
    } catch (e) {
      return false;
    }
  }
}
