class FamiliaOlfativaModel {
  final int? id;
  final String nombre;

  FamiliaOlfativaModel({this.id, required this.nombre});

  factory FamiliaOlfativaModel.fromJson(Map<String, dynamic> json) =>
      FamiliaOlfativaModel(id: json['id'], nombre: json['nombre']);

  Map<String, dynamic> toJson() => {'nombre': nombre};
}
