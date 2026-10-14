import 'variante_model.dart';
import 'galeria_model.dart';

class ProductoModel {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String? imagenPrincipal;
  final int? categoriaId;
  final int? marcaId;
  final int? concentracionId;
  final int? familiaOlfativaId;
  final String? ocasion;
  final String? estacion;

  // Relaciones anidadas
  final List<VarianteModel> variantes;
  final List<GaleriaModel> galerias;

  ProductoModel({
    this.id,
    required this.nombre,
    this.descripcion,
    this.imagenPrincipal,
    this.categoriaId,
    this.marcaId,
    this.concentracionId,
    this.familiaOlfativaId,
    this.ocasion,
    this.estacion,
    this.variantes = const [],
    this.galerias = const [],
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      imagenPrincipal: json['imagen_principal'],
      categoriaId: json['categoria_id'] != null
          ? (json['categoria_id'] as num).toInt()
          : null,
      marcaId: json['marca_id'] != null
          ? (json['marca_id'] as num).toInt()
          : null,
      concentracionId: json['concentracion_id'] != null
          ? (json['concentracion_id'] as num).toInt()
          : null,
      familiaOlfativaId: json['familia_olfativa_id'] != null
          ? (json['familia_olfativa_id'] as num).toInt()
          : null,
      ocasion: json['ocasion'],
      estacion: json['estacion'],
      variantes: json['variantes'] != null
          ? (json['variantes'] as List)
                .map((v) => VarianteModel.fromJson(v as Map<String, dynamic>))
                .toList()
          : [],
      galerias: json['galerias'] != null
          ? (json['galerias'] as List)
                .map((g) => GaleriaModel.fromJson(g as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'imagen_principal': imagenPrincipal,
    'categoria_id': categoriaId,
    'marca_id': marcaId,
    'concentracion_id': concentracionId,
    'familia_olfativa_id': familiaOlfativaId,
    'ocasion': ocasion,
    'estacion': estacion,
  };

  // Método opcional pero muy recomendado para actualizar datos en Flutter
  ProductoModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? imagenPrincipal,
    int? categoriaId,
    int? marcaId,
    int? concentracionId,
    int? familiaOlfativaId,
    String? ocasion,
    String? estacion,
    List<VarianteModel>? variantes,
    List<GaleriaModel>? galerias,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imagenPrincipal: imagenPrincipal ?? this.imagenPrincipal,
      categoriaId: categoriaId ?? this.categoriaId,
      marcaId: marcaId ?? this.marcaId,
      concentracionId: concentracionId ?? this.concentracionId,
      familiaOlfativaId: familiaOlfativaId ?? this.familiaOlfativaId,
      ocasion: ocasion ?? this.ocasion,
      estacion: estacion ?? this.estacion,
      variantes: variantes ?? this.variantes,
      galerias: galerias ?? this.galerias,
    );
  }
}
