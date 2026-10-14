import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/alertas_model.dart';
import '../../../data/providers/alerta_provider.dart';

class AlertaExpandableCard extends StatelessWidget {
  final AlertaStockModel alerta;

  const AlertaExpandableCard({super.key, required this.alerta});

  @override
  Widget build(BuildContext context) {
    const Color redAlertColor = Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: alerta.imagenUrl != null && alerta.imagenUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        alerta.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
            ),
            title: Text(
              alerta.nombreProducto,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                alerta.nombreVariante != null
                    ? 'Variante: ${alerta.nombreVariante}'
                    : 'Variante #${alerta.varianteId}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: redAlertColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${alerta.stockActual} ud.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: redAlertColor,
                ),
              ),
            ),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajustar stock rápido:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      _buildBotonAccion(
                        icono: Icons.remove,
                        color: Colors.grey.shade700,
                        onTap: () => context
                            .read<AlertaProvider>()
                            .modificarStock(alerta, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${alerta.stockActual}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      _buildBotonAccion(
                        icono: Icons.add,
                        color: const Color(0xFF10B981),
                        onTap: () => context
                            .read<AlertaProvider>()
                            .modificarStock(alerta, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonAccion({
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icono, size: 16, color: color),
        ),
      ),
    );
  }
}


