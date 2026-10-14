import 'package:flutter/material.dart';
import '../../../data/models/estadistica_model.dart';

class RankingTop10Widget extends StatelessWidget {
  final List<ItemRankingModel> listaTop;

  const RankingTop10Widget({super.key, required this.listaTop});

  @override
  Widget build(BuildContext context) {
    if (listaTop.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay datos de ventas registrados'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listaTop.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = listaTop[index];
        final posicion = index + 1;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: posicion <= 3
                ? const Color(0xFF4A1519)
                : Colors.grey[300],
            child: Text(
              '#$posicion',
              style: TextStyle(
                color: posicion <= 3 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            item.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${item.unidadesVendidas} unidades vendidas'),
          trailing: Text(
            '\$${item.totalRecaudado.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}
