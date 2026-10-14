import 'package:supabase_flutter/supabase_flutter.dart';

class PedidoDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPedidosWithDetails() async {
    final response = await _client
        .from('pedidos')
        .select('''
      id,
      usuario_id,
      fecha,
      estado,
      usuario:perfiles!pedidos_usuario_id_fkey(nombre),
      pedido_detalles(
        id,
        pedido_id,
        variante_id,
        cantidad,
        precio_unitario,
        variantes(
          id,
          sku,
          mililitros,
          stock,
          precio_venta,
          productos(
            id,
            nombre,
            imagen_principal
          )
        )
      )
    ''')
        .order('fecha', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<int> insertPedido({
    required String? usuarioId,
    required String estado,
  }) async {
    final response = await _client
        .from('pedidos')
        .insert({'usuario_id': usuarioId, 'estado': estado})
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<void> insertPedidoDetalles(List<Map<String, dynamic>> detalles) async {
    await _client.from('pedido_detalles').insert(detalles);
  }

  Future<void> updateEstadoPedido(int pedidoId, String nuevoEstado) async {
    await _client
        .from('pedidos')
        .update({'estado': nuevoEstado})
        .eq('id', pedidoId);
  }

  Future<void> deletePedido(int pedidoId) async {
    await _client.from('pedidos').delete().eq('id', pedidoId);
  }
}
