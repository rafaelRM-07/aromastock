class ConcentracionModel {
  final int? id;
  final String nombre;

  ConcentracionModel({this.id, required this.nombre});

  factory ConcentracionModel.fromJson(Map<String, dynamic> json) =>
      ConcentracionModel(id: json['id'], nombre: json['nombre']);

  Map<String, dynamic> toJson() => {'nombre': nombre};
}
