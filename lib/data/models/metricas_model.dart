class MetricsModel {
  final double ventaTotal;
  final int perfumesActivos;
  final int alertasStockBajo;

  MetricsModel({
    required this.ventaTotal,
    required this.perfumesActivos,
    required this.alertasStockBajo,
  });

  factory MetricsModel.empty() =>
      MetricsModel(ventaTotal: 0.0, perfumesActivos: 0, alertasStockBajo: 0);
}
