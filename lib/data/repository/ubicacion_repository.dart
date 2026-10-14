import '../database/supabase/ubicacion_database.dart';
import '../models/ubicacion_model.dart';

class UbicacionRepository {
  final _db = UbicacionDatabase();

  // Obtener todas las ubicaciones
  Future<List<UbicacionModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((e) => UbicacionModel.fromJson(e)).toList();
  }

  // Insertar una nueva ubicación
  Future<void> insertar(UbicacionModel model) async {
    await _db.insert(model.toJson());
  }

  // Actualizar una ubicación existente
  Future<void> actualizar(UbicacionModel model) async {
    if (model.id == null) {
      throw Exception("ID de ubicación requerido para actualizar");
    }
    await _db.update(model.id!, model.toJson());
  }

  // Eliminar una ubicación
  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }
}
