import 'package:supabase_flutter/supabase_flutter.dart';

class ProveedorDatabase {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client.from('proveedores').select().order('nombre_empresa');
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('proveedores').insert(data);
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('proveedores').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('proveedores').delete().eq('id', id);
  }
}
