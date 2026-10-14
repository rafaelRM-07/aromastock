import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/pedido_model.dart';
import '../../../data/providers/pedido_provider.dart';

class PedidoExpandableCard extends StatefulWidget {
  final PedidoModel pedido;

  const PedidoExpandableCard({super.key, required this.pedido});

  @override
  State<PedidoExpandableCard> createState() => _PedidoExpandableCardState();
}

class _PedidoExpandableCardState extends State<PedidoExpandableCard> {
  bool _isProcessing = false;

  // Paleta de colores más sutil y profesional
  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'despachado':
        return const Color(0xFF10B981); // Esmeralda moderno
      case 'cancelado':
      case 'rechazado':
        return const Color(0xFFEF4444); // Rojo suave
      case 'pendiente':
      default:
        return const Color(0xFFF59E0B); // Ámbar elegante
    }
  }

  IconData _obtenerIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'despachado':
        return Icons.check_rounded;
      case 'cancelado':
      case 'rechazado':
        return Icons.close_rounded;
      case 'pendiente':
      default:
        return Icons.schedule_rounded;
    }
  }

  Future<void> _actualizarEstado(
    BuildContext context,
    String nuevoEstado,
  ) async {
    final provider = context.read<PedidoProvider>();

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Cambiar estado a $nuevoEstado?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de marcar el Pedido #${widget.pedido.id} como "$nuevoEstado"?',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado.toLowerCase() == 'despachado'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isProcessing = true);
    final exito = await provider.cambiarEstado(widget.pedido.id, nuevoEstado);

    if (!context.mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito
              ? 'Pedido #${widget.pedido.id} actualizado a $nuevoEstado.'
              : 'Error al actualizar el pedido.',
        ),
        backgroundColor: exito
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _obtenerColorEstado(widget.pedido.estado);
    final fechaStr = DateFormat(
      'dd/MM/yyyy • hh:mm a',
    ).format(widget.pedido.fecha);
    final bool esPendiente = widget.pedido.estado.toLowerCase() == 'pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorEstado.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _obtenerIconoEstado(widget.pedido.estado),
                color: colorEstado,
                size: 20,
              ),
            ),
            title: Text(
              'Pedido #${widget.pedido.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${widget.pedido.detalles.length} ítem(s) • $fechaStr',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${widget.pedido.totalPedido.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.pedido.estado.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: colorEstado,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 14),

              // Cliente (si existe)
              if (widget.pedido.nombreUsuario != null) ...[
                _buildFilaInfo('Cliente', widget.pedido.nombreUsuario!),
                const SizedBox(height: 12),
              ],

              const Text(
                'Productos del pedido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),

              // Lista de ítems con diseño limpio
              ...widget.pedido.detalles.map(
                (det) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              det.nombrePerfume ??
                                  'Producto #${det.varianteId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (det.nombreVariante != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                det.nombreVariante!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${det.cantidad}x \$${det.precioUnitario.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botones de Acción (Solo si está pendiente)
              if (esPendiente) ...[
                const SizedBox(height: 12),
                _isProcessing
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4A0E0E),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () =>
                                  _actualizarEstado(context, 'Cancelado'),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFFEF4444),
                                size: 16,
                              ),
                              label: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () =>
                                  _actualizarEstado(context, 'Despachado'),
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Despachar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilaInfo(String titulo, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
