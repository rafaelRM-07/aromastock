import '../database/supabase/pedido_database.dart';
import '../models/pedido_model.dart';

class PedidoRepository {
  final PedidoDatabase _database;

  PedidoRepository({PedidoDatabase? database})
    : _database = database ?? PedidoDatabase();

  Future<List<PedidoModel>> obtenerPedidos() async {
    try {
      final rawData = await _database.fetchPedidosWithDetails();
      return rawData.map((map) => PedidoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener pedidos del repositorio: $e');
    }
  }

  Future<int> crearPedido({
    required String? usuarioId,
    required List<Map<String, dynamic>> detalles,
  }) async {
    try {
      final pedidoId = await _database.insertPedido(
        usuarioId: usuarioId,
        estado: 'Pendiente',
      );

      final listaDetallesFormat = detalles.map((d) {
        return {
          'pedido_id': pedidoId,
          'variante_id': d['variante_id'],
          'cantidad': d['cantidad'],
          'precio_unitario': d['precio_unitario'],
        };
      }).toList();

      await _database.insertPedidoDetalles(listaDetallesFormat);

      return pedidoId;
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
  }

  Future<void> actualizarEstado(int pedidoId, String nuevoEstado) async {
    try {
      await _database.updateEstadoPedido(pedidoId, nuevoEstado);
    } catch (e) {
      throw Exception('Error al actualizar el estado del pedido: $e');
    }
  }

  Future<void> eliminarPedido(int pedidoId) async {
    try {
      await _database.deletePedido(pedidoId);
    } catch (e) {
      throw Exception('Error al eliminar el pedido: $e');
    }
  }
}
