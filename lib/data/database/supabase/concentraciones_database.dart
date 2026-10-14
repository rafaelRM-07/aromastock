import 'package:supabase_flutter/supabase_flutter.dart';

class ConcentracionDatabase {
  final _client = Supabase.instance.client;

  /// Obtiene todas las concentraciones ordenadas por nombre
  Future<List<Map<String, dynamic>>> fetchAll() =>
      _client.from('concentraciones').select().order('nombre');

  /// Inserta una nueva concentración
  Future<void> insert(Map<String, dynamic> data) =>
      _client.from('concentraciones').insert(data);

  /// Actualiza una concentración específica por su ID
  Future<void> update(int id, Map<String, dynamic> data) =>
      _client.from('concentraciones').update(data).eq('id', id);

  /// Elimina una concentración específica por su ID
  Future<void> delete(int id) =>
      _client.from('concentraciones').delete().eq('id', id);
}
