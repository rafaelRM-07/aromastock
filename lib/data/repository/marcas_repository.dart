import '../database/supabase/marcas_database.dart';
import '../models/marcas_model.dart';

class MarcaRepository {
  final _db = MarcaDatabase();

  Future<List<MarcaModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((e) => MarcaModel.fromJson(e)).toList();
  }

  Future<void> insertar(MarcaModel m) => _db.insert(m.toJson());

  Future<void> actualizar(MarcaModel m) => _db.update(m.id!, m.toJson());

  Future<void> eliminar(int id) => _db.delete(id);
}
