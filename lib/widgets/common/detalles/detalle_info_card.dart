import 'package:flutter/material.dart';
import '../../../../data/models/productos_model.dart';

class DetalleInfoCardWidget extends StatelessWidget {
  final ProductoModel producto;

  const DetalleInfoCardWidget({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información General',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (producto.marcaId != null)
                Expanded(
                  child: _itemInfo(
                    'Marca ID',
                    '${producto.marcaId}',
                    Icons.branding_watermark,
                  ),
                ),
              if (producto.categoriaId != null)
                Expanded(
                  child: _itemInfo(
                    'Categoría ID',
                    '${producto.categoriaId}',
                    Icons.category,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (producto.concentracionId != null)
                Expanded(
                  child: _itemInfo(
                    'Concentración ID',
                    '${producto.concentracionId}',
                    Icons.science,
                  ),
                ),
              if (producto.familiaOlfativaId != null)
                Expanded(
                  child: _itemInfo(
                    'Familia Olfativa ID',
                    '${producto.familiaOlfativaId}',
                    Icons.local_florist,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemInfo(String titulo, String valor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6A1B29)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              valor,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
