import 'package:supabase_flutter/supabase_flutter.dart';

class DetalleProductoDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getProductoConVariantes(int productoId) async {
    final response = await _client
        .from('productos')
        .select('''
          *,
          variantes (*)
        ''')
        .eq('id', productoId)
        .maybeSingle();

    return response;
  }
}
