import '../database/supabase/movimiento_database.dart';
import '../models/movimiento_model.dart';

class MovimientoRepository {
  final MovimientoDatabase _database = MovimientoDatabase();

  /// Obtiene y transforma todos los registros a una lista de modelos
  Future<List<MovimientoModel>> getTodoElHistorial() async {
    final List<Map<String, dynamic>> rawData = await _database
        .fetchTodoElHistorial();
    return rawData.map((map) => MovimientoModel.fromMap(map)).toList();
  }

  /// Obtiene los movimientos filtrados por variante
  Future<List<MovimientoModel>> getMovimientosPorVariante(
    int varianteId,
  ) async {
    final List<Map<String, dynamic>> rawData = await _database
        .fetchMovimientosPorVariante(varianteId);
    return rawData.map((map) => MovimientoModel.fromMap(map)).toList();
  }

  /// Registra un nuevo movimiento
  Future<void> registrarMovimiento(MovimientoModel movimiento) async {
    await _database.insertMovimiento(movimiento.toMap());
  }
}
