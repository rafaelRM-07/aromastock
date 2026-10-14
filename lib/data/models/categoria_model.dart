class CategoriaModel {
  final int? id;
  final String nombre;
  final String? descripcion;

  CategoriaModel({this.id, required this.nombre, this.descripcion});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) => CategoriaModel(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
  };
}
