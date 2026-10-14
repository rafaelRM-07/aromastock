class PedidoDetalleModel {
  final int id;
  final int pedidoId;
  final int varianteId;
  final int cantidad;
  final double precioUnitario;

  // Información de las relaciones
  final String? nombrePerfume;
  final String? nombreVariante;
  final String? imagenUrl;

  PedidoDetalleModel({
    required this.id,
    required this.pedidoId,
    required this.varianteId,
    required this.cantidad,
    required this.precioUnitario,
    this.nombrePerfume,
    this.nombreVariante,
    this.imagenUrl,
  });

  double get subtotal => cantidad * precioUnitario;

  factory PedidoDetalleModel.fromMap(Map<String, dynamic> map) {
    final variante = map['variantes'] as Map<String, dynamic>?;
    final producto = variante != null
        ? variante['productos'] as Map<String, dynamic>?
        : null;

    String? varianteLabel;
    if (variante != null) {
      if (variante['mililitros'] != null) {
        varianteLabel = '${variante['mililitros']} ml';
      } else if (variante['sku'] != null) {
        varianteLabel = 'SKU: ${variante['sku']}';
      }
    }

    return PedidoDetalleModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      pedidoId: map['pedido_id'] is int
          ? map['pedido_id']
          : int.parse(map['pedido_id'].toString()),
      varianteId: map['variante_id'] is int
          ? map['variante_id']
          : int.parse(map['variante_id'].toString()),
      cantidad: map['cantidad'] is int
          ? map['cantidad']
          : int.parse(map['cantidad'].toString()),
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      nombrePerfume: producto?['nombre'],
      nombreVariante: varianteLabel,
      imagenUrl: producto?['imagen_principal'],
    );
  }
}

class PedidoModel {
  final int id;
  final String? usuarioId;
  final DateTime fecha;
  final String estado;
  final String? nombreUsuario;
  final List<PedidoDetalleModel> detalles;

  PedidoModel({
    required this.id,
    this.usuarioId,
    required this.fecha,
    required this.estado,
    this.nombreUsuario,
    this.detalles = const [],
  });

  double get totalPedido =>
      detalles.fold(0.0, (sum, item) => sum + item.subtotal);

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    final usuarioObj = map['usuario'] as Map<String, dynamic>?;

    final listaDetallesRaw = map['pedido_detalles'] as List<dynamic>? ?? [];
    final detallesParsed = listaDetallesRaw
        .map((d) => PedidoDetalleModel.fromMap(d as Map<String, dynamic>))
        .toList();

    return PedidoModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      usuarioId: map['usuario_id']?.toString(),
      fecha: DateTime.parse(map['fecha']),
      estado: map['estado'] ?? 'Pendiente',
      nombreUsuario: usuarioObj?['nombre'],
      detalles: detallesParsed,
    );
  }
}
