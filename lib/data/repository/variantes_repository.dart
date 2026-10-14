import '../database/supabase/variantes_database.dart';
import '../models/variante_model.dart';

class VarianteRepository {
  final _db = VarianteDatabase();

  Future<List<VarianteModel>> listarPorProducto(int productoId) async {
    final data = await _db.fetchByProducto(productoId);
    return data.map((json) => VarianteModel.fromJson(json)).toList();
  }

  // Busca la variante por SKU y la convierte al modelo VarianteModel
  Future<VarianteModel?> obtenerPorSku(String sku) async {
    final data = await _db.fetchBySku(sku);
    if (data == null) return null;
    return VarianteModel.fromJson(data);
  }

  Future<void> insertar(VarianteModel variante) async {
    await _db.insert(variante.toJson());
  }

  Future<void> actualizar(VarianteModel variante) async {
    if (variante.id == null) throw Exception("ID requerido");
    await _db.update(variante.id!, variante.toJson());
  }

  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }

  Future<List<VarianteModel>> listarTodas() async {
    final data = await _db.fetchAll();
    return data.map((json) => VarianteModel.fromJson(json)).toList();
  }
}
