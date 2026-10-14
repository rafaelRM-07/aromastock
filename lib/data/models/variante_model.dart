class VarianteModel {
  final int? id;
  final int productoId;
  final String sku;
  final int? mililitros;
  final int stock;
  final double costoCompra;
  final double precioVenta;
  final int? ubicacionId;
  final bool activo;
  final String? nombreProducto;

  VarianteModel({
    this.id,
    required this.productoId,
    required this.sku,
    this.mililitros,
    this.stock = 0,
    required this.costoCompra,
    required this.precioVenta,
    this.ubicacionId,
    this.activo = true,
    this.nombreProducto,
  });

  factory VarianteModel.fromJson(Map<String, dynamic> json) {
    String? nombreExtraido;
    if (json['productos'] != null && json['productos'] is Map) {
      nombreExtraido = json['productos']['nombre'];
    }
    return VarianteModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      productoId: (json['producto_id'] as num).toInt(),
      sku: json['sku'] ?? '',
      mililitros: json['mililitros'] != null
          ? (json['mililitros'] as num).toInt()
          : null,
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : 0,
      costoCompra: (json['costo_compra'] as num).toDouble(),
      precioVenta: (json['precio_venta'] as num).toDouble(),
      ubicacionId: json['ubicacion_id'] != null
          ? (json['ubicacion_id'] as num).toInt()
          : null,
      activo: json['activo'] ?? true,
      nombreProducto: nombreExtraido,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'producto_id': productoId,
    'sku': sku,
    'mililitros': mililitros,
    'stock': stock,
    'costo_compra': costoCompra,
    'precio_venta': precioVenta,
    'ubicacion_id': ubicacionId,
    'activo': activo,
  };
}
