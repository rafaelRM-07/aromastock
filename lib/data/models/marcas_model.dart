class MarcaModel {
  final int? id;
  final String nombre;

  MarcaModel({this.id, required this.nombre});

  factory MarcaModel.fromJson(Map<String, dynamic> json) =>
      MarcaModel(id: json['id'], nombre: json['nombre']);

  Map<String, dynamic> toJson() => {'nombre': nombre};
}
