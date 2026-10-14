import '../database/supabase/familia_olfativa_database.dart';
import '../models/familia_olfativa_model.dart';

class FamiliaOlfativaRepository {
  final _db = FamiliaOlfativaDatabase();

  Future<List<FamiliaOlfativaModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((e) => FamiliaOlfativaModel.fromJson(e)).toList();
  }

  Future<void> insertar(FamiliaOlfativaModel model) async {
    await _db.insert(model.toJson());
  }

  Future<void> actualizar(FamiliaOlfativaModel model) async {
    if (model.id == null) throw Exception("ID requerido");
    await _db.update(model.id!, model.toJson());
  }

  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }
}
