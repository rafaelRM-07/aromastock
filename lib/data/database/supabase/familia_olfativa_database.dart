import 'package:supabase_flutter/supabase_flutter.dart';

class FamiliaOlfativaDatabase {
  final _client = Supabase.instance.client;

  ///
  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client.from('familias_olfativas').select().order('nombre');
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('familias_olfativas').insert(data);
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('familias_olfativas').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('familias_olfativas').delete().eq('id', id);
  }
}
