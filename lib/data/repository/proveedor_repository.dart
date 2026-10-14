import '../database/supabase/proveedor_database.dart';
import '../models/proveedor_model.dart';

class ProveedorRepository {
  final _db = ProveedorDatabase();

  Future<List<ProveedorModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((e) => ProveedorModel.fromJson(e)).toList();
  }

  Future<void> insertar(ProveedorModel model) async {
    await _db.insert(model.toJson());
  }

  Future<void> actualizar(ProveedorModel model) async {
    if (model.id == null) {
      throw Exception("ID requerido");
    }
    await _db.update(model.id!, model.toJson());
  }

  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }
}
