import 'package:supabase_flutter/supabase_flutter.dart';

class VarianteDatabase {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchByProducto(int productoId) async {
    return await _client
        .from('variantes')
        .select('*, productos(nombre)')
        .eq('producto_id', productoId);
  }
  //

  Future<Map<String, dynamic>?> fetchBySku(String sku) async {
    return await _client
        .from('variantes')
        .select('*, productos(nombre)')
        .eq('sku', sku)
        .maybeSingle();
  }

  //
  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client
        .from('variantes')
        .select('*, productos(nombre)')
        .order('sku', ascending: true);
  }

  //
  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('variantes').insert(data);
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('variantes').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('variantes').delete().eq('id', id);
  }
}
