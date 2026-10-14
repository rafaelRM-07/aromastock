class UbicacionModel {
  final int? id;
  final String zona;
  final String estante;
  final String estadoLogistico; // REPOSO, OCUPADO, etc.

  UbicacionModel({
    this.id,
    required this.zona,
    required this.estante,
    this.estadoLogistico = 'REPOSO',
  });

  factory UbicacionModel.fromJson(Map<String, dynamic> json) => UbicacionModel(
    id: json['id'],
    zona: json['zona'],
    estante: json['estante'],
    estadoLogistico: json['estado_logistico'],
  );

  Map<String, dynamic> toJson() => {
    'zona': zona,
    'estante': estante,
    'estado_logistico': estadoLogistico,
  };
}
