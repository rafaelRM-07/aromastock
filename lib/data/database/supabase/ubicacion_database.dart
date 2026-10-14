import 'package:supabase_flutter/supabase_flutter.dart';

class UbicacionDatabase {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client.from('ubicaciones').select().order('zona');
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('ubicaciones').insert(data);
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('ubicaciones').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('ubicaciones').delete().eq('id', id);
  }
}
