import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/estadistica_model.dart';

class GraficaTopMarcasWidget extends StatelessWidget {
  final List<ItemMarcaValorModel> datos;

  const GraficaTopMarcasWidget({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sin datos de marcas registrados'),
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
              sideTitles: SideTitles(showTitles: true, reservedSize: 45),
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
                    final marca = datos[index].marca;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        marca.length > 7 ? '${marca.substring(0, 7)}..' : marca,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
                  toY: item.valorTotal,
                  color: const Color(0xFFD4A373),
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
