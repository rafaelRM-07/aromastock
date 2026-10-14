import 'package:flutter/material.dart';
import '../../../../data/models/productos_model.dart';

class DetalleHeaderWidget extends StatelessWidget {
  final ProductoModel producto;

  const DetalleHeaderWidget({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGEN PRINCIPAL DEL PERFUME
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                producto.imagenPrincipal != null &&
                    producto.imagenPrincipal!.isNotEmpty
                ? Image.network(
                    producto.imagenPrincipal!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // NOMBRE DEL PRODUCTO
        Text(
          producto.nombre,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        // DESCRIPCIÓN
        if (producto.descripcion != null &&
            producto.descripcion!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            producto.descripcion!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],

        // OCASIÓN Y ESTACIÓN
        if ((producto.ocasion != null && producto.ocasion!.isNotEmpty) ||
            (producto.estacion != null && producto.estacion!.isNotEmpty)) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (producto.ocasion != null && producto.ocasion!.isNotEmpty)
                Expanded(
                  child: _buildBadge('Ocasión', producto.ocasion!, Icons.event),
                ),
              if (producto.ocasion != null && producto.estacion != null)
                const SizedBox(width: 10),
              if (producto.estacion != null && producto.estacion!.isNotEmpty)
                Expanded(
                  child: _buildBadge(
                    'Estación',
                    producto.estacion!,
                    Icons.wb_sunny,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B29).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6A1B29).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A1B29)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B29),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
