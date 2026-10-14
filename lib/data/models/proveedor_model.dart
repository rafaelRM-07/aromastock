class ProveedorModel {
  final int? id;
  final String nombreEmpresa;
  final String? contactoNombre;
  final String? telefono;
  final String? correo;

  ProveedorModel({
    this.id,
    required this.nombreEmpresa,
    this.contactoNombre,
    this.telefono,
    this.correo,
  });

  factory ProveedorModel.fromJson(Map<String, dynamic> json) => ProveedorModel(
    id: json['id'],
    nombreEmpresa: json['nombre_empresa'],
    contactoNombre: json['contacto_nombre'],
    telefono: json['telefono'],
    correo: json['correo'],
  );

  Map<String, dynamic> toJson() => {
    'nombre_empresa': nombreEmpresa,
    'contacto_nombre': contactoNombre,
    'telefono': telefono,
    'correo': correo,
  };
}
