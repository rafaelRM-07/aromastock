class PerfilModel {
  final String id;
  final String nombre;
  final String rol;
  final bool activo;

  PerfilModel({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.activo,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'rol': rol, 'activo': activo};
  }
}
