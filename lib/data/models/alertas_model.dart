class AlertaStockModel {
  final int id;
  final int varianteId;
  final int stockMinimo;
  int stockActual; // Se permite modificar localmente al interactuar con + y -
  final String nombreProducto;
  final String? nombreVariante;
  final String? imagenUrl;

  AlertaStockModel({
    required this.id,
    required this.varianteId,
    required this.stockMinimo,
    required this.stockActual,
    required this.nombreProducto,
    this.nombreVariante,
    this.imagenUrl,
  });

  factory AlertaStockModel.fromMap(Map<String, dynamic> map) {
    final variante = map['variantes'] as Map<String, dynamic>? ?? {};
    final producto = variante['productos'] as Map<String, dynamic>? ?? {};

    final ml = variante['mililitros'];

    return AlertaStockModel(
      id: map['id'] ?? 0,
      varianteId: map['variante_id'] ?? 0,
      stockMinimo: map['stock_minimo'] ?? 5,
      stockActual: variante['stock'] ?? 0,
      nombreProducto: producto['nombre'] ?? 'Producto sin nombre',
      nombreVariante: ml != null ? '$ml ml' : null,
      imagenUrl: producto['imagen_principal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'variante_id': varianteId, 'stock_minimo': stockMinimo};
  }
}
