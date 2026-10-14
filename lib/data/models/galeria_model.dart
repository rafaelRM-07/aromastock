class GaleriaModel {
  final int? id;
  final int productoId;
  final String rutaImagen;

  GaleriaModel({this.id, required this.productoId, required this.rutaImagen});

  factory GaleriaModel.fromJson(Map<String, dynamic> json) {
    return GaleriaModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      productoId: (json['producto_id'] as num).toInt(),
      rutaImagen: json['ruta_imagen'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'producto_id': productoId,
    'ruta_imagen': rutaImagen,
  };
}
