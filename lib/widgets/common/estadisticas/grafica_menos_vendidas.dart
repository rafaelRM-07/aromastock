import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/estadistica_model.dart';

class GraficaMenosVendidasWidget extends StatelessWidget {
  final List<ItemRankingModel> datos;

  const GraficaMenosVendidasWidget({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sin datos registrados'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
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
                    final nombre = datos[index].nombre;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        nombre.length > 7
                            ? '${nombre.substring(0, 7)}...'
                            : nombre,
                        style: const TextStyle(fontSize: 10),
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
                  toY: item.unidadesVendidas.toDouble(),
                  color: Colors.redAccent,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
