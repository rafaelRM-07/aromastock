import 'package:supabase_flutter/supabase_flutter.dart';

class GaleriaDatabase {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchByProducto(int productoId) async {
    return await _client
        .from('galerias')
        .select()
        .eq('producto_id', productoId);
  }

  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from('galerias').insert(data);
  }

  Future<void> delete(int id) async {
    await _client.from('galerias').delete().eq('id', id);
  }
}
