import '../database/supabase/concentraciones_database.dart';
import '../models/concentraciones_model.dart';

class ConcentracionRepository {
  final _db = ConcentracionDatabase();

  Future<List<ConcentracionModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((e) => ConcentracionModel.fromJson(e)).toList();
  }

  Future<void> insertar(ConcentracionModel model) => _db.insert(model.toJson());

  Future<void> actualizar(ConcentracionModel model) =>
      _db.update(model.id!, model.toJson());

  Future<void> eliminar(int id) => _db.delete(id);
}
