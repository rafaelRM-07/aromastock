import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/estadisticas_provider.dart';

class GraficaActividadDashboardWidget extends StatelessWidget {
  const GraficaActividadDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstadisticasProvider>();

    if (provider.cargando && provider.reporte == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A1519),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final datos = provider.reporte?.flujoMovimientos ?? [];

    return Container(
      // Reducimos un poco el padding horizontal a 10 para ganar espacio
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado protegido contra desbordamientos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded evita el desbordamiento horizontal en pantallas estrechas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Actividad',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Entradas/Salidas',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _puntoLeyenda(Colors.green, 'In'),
                  const SizedBox(width: 4),
                  _puntoLeyenda(const Color(0xFF4A1519), 'Out'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Gráfica de Barras
          if (datos.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Sin registros',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _obtenerMaxY(datos),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index >= 0 && index < datos.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                datos[index].fechaLabel,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(datos.length, (index) {
                    final item = datos[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.entradas.toDouble(),
                          color: Colors.green,
                          width: 4.5,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: item.salidas.toDouble(),
                          color: const Color(0xFF4A1519),
                          width: 4.5,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _puntoLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 2),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  double _obtenerMaxY(List datos) {
    double maxVal = 10;
    for (var item in datos) {
      if (item.entradas > maxVal) maxVal = item.entradas.toDouble();
      if (item.salidas > maxVal) maxVal = item.salidas.toDouble();
    }
    return maxVal + 2;
  }
}
