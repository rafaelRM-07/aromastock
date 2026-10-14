class MovimientoModel {
  final int id;
  final int varianteId;
  final String? perfilId;
  final String tipoMovimiento;
  final int cantidad;
  final double? costoHistorico;
  final String? motivo;
  final DateTime fecha;

  // Propiedades obtenidas mediante los JOINs
  final String? nombreVariante; // Ej: "100 ml" o "SKU: XXX"
  final String? nombrePerfume; // Nombre del producto padre

  MovimientoModel({
    required this.id,
    required this.varianteId,
    this.perfilId,
    required this.tipoMovimiento,
    required this.cantidad,
    this.costoHistorico,
    this.motivo,
    required this.fecha,
    this.nombreVariante,
    this.nombrePerfume,
  });

  factory MovimientoModel.fromMap(Map<String, dynamic> map) {
    final varianteMap = map['variantes'] as Map<String, dynamic>?;
    final productoMap = varianteMap?['productos'] as Map<String, dynamic>?;

    // Formatear la variante (ej. "100 ml" o "SKU: ABC")
    String? textoVariante;
    if (varianteMap != null) {
      if (varianteMap['mililitros'] != null) {
        textoVariante = '${varianteMap['mililitros']} ml';
      } else if (varianteMap['sku'] != null) {
        textoVariante = 'SKU: ${varianteMap['sku']}';
      }
    }

    return MovimientoModel(
      id: map['id'] as int,
      varianteId: map['variante_id'] as int,
      perfilId: map['perfil_id'] as String?,
      tipoMovimiento: map['tipo_movimiento'] as String,
      cantidad: map['cantidad'] as int,
      costoHistorico: map['costo_historico'] != null
          ? (map['costo_historico'] as num).toDouble()
          : null,
      motivo: map['motivo'] as String?,
      fecha: DateTime.parse(map['fecha'] as String),
      nombreVariante: textoVariante,
      nombrePerfume: productoMap?['nombre'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (perfilId != null) 'perfil_id': perfilId,
      'variante_id': varianteId,
      'tipo_movimiento': tipoMovimiento,
      'cantidad': cantidad,
      'costo_historico': costoHistorico,
      'motivo': motivo,
      'fecha': fecha.toIso8601String(),
    };
  }
}
