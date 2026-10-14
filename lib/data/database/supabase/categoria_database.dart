import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriaDatabase {
  final _client = Supabase.instance.client;

  /// Obtiene todas las categorías ordenadas por nombre
  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client.from('categorias').select().order('nombre');
  }

  /// Inserta una nueva categoría
  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('categorias').insert(data);
  }

  /// Actualiza una categoría específica por su ID
  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('categorias').update(data).eq('id', id);
  }

  /// Elimina una categoría específica por su ID
  Future<void> delete(int id) async {
    await _client.from('categorias').delete().eq('id', id);
  }
}
