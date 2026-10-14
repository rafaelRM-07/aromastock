import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/estadistica_model.dart';

class GraficaFamiliasWidget extends StatelessWidget {
  final List<ItemFamiliaModel> datos;

  const GraficaFamiliasWidget({super.key, required this.datos});

  static const _colores = [
    Color(0xFF4A1519),
    Color(0xFF8B263E),
    Color(0xFFD4A373),
    Color(0xFF2A9D8F),
    Color(0xFFE76F51),
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sin datos disponibles'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(datos.length, (index) {
                final item = datos[index];

                return PieChartSectionData(
                  color: _colores[index % _colores.length],
                  value: item.cantidad,
                  title: '${item.cantidad.toInt()}',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: List.generate(datos.length, (index) {
            final item = datos[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colores[index % _colores.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(item.familia, style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
      ],
    );
  }
}
