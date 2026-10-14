import 'package:supabase_flutter/supabase_flutter.dart';

class MarcaDatabase {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() =>
      _client.from('marcas').select().order('nombre');

  Future<void> insert(Map<String, dynamic> data) =>
      _client.from('marcas').insert(data);

  Future<void> update(int id, Map<String, dynamic> data) =>
      _client.from('marcas').update(data).eq('id', id);

  Future<void> delete(int id) => _client.from('marcas').delete().eq('id', id);
}
