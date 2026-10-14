import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/estadistica_model.dart';

class GraficaFlujoMovimientosWidget extends StatelessWidget {
  final List<ItemFlujoMovimientoModel> datos;

  const GraficaFlujoMovimientosWidget({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sin datos de movimientos registrados'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            datos[index].fechaLabel,
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
                      toY: item.entradas.toDouble(),
                      color: Colors.green,
                      width: 10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: item.salidas.toDouble(),
                      color: const Color(0xFF4A1519),
                      width: 10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _leyendaItem(Colors.green, 'Entradas'),
            const SizedBox(width: 20),
            _leyendaItem(const Color(0xFF4A1519), 'Salidas'),
          ],
        ),
      ],
    );
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
