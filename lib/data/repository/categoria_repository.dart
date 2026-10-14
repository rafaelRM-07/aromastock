import '../database/supabase/categoria_database.dart';
import '../models/categoria_model.dart';

class CategoriaRepository {
  final _db = CategoriaDatabase();

  Future<List<CategoriaModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((json) => CategoriaModel.fromJson(json)).toList();
  }

  Future<void> insertar(CategoriaModel categoria) async {
    await _db.insert(categoria.toJson());
  }

  Future<void> actualizar(CategoriaModel categoria) async {
    if (categoria.id == null) throw Exception("ID requerido para actualizar");
    await _db.update(categoria.id!, categoria.toJson());
  }

  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }
}
