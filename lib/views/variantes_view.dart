import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/variante_model.dart';
import '../../data/providers/variantes_provider.dart';
import '../widgets/forms/variante_form.dart';

class VariantesView extends StatefulWidget {
  final int productoId;
  final bool abrirFormularioAlInicio;

  const VariantesView({
    super.key,
    required this.productoId,
    this.abrirFormularioAlInicio = false,
  });

  @override
  State<VariantesView> createState() => _VariantesViewState();
}

class _VariantesViewState extends State<VariantesView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<VarianteProvider>();
        provider.cargarPorProducto(widget.productoId);
        provider.initRealtime(widget.productoId);

        if (widget.abrirFormularioAlInicio) {
          _mostrarFormularioVariante();
        }
      }
    });
  }

  void _mostrarFormularioVariante({VarianteModel? variante}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: VarianteForm(
              productoId: widget.productoId,
              variante: variante,
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(VarianteModel variante) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Variante'),
        content: Text(
          '¿Deseas eliminar la variante con SKU "${variante.sku}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (variante.id != null) {
                await context.read<VarianteProvider>().eliminar(
                  variante.id!,
                  widget.productoId,
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final varianteProvider = context.watch<VarianteProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A1B29),
        title: const Text(
          'Variantes del Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: (varianteProvider.cargando && varianteProvider.variantes.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B29)),
            )
          : varianteProvider.variantes.isEmpty
          ? const Center(
              child: Text(
                'No hay variantes registradas',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: varianteProvider.variantes.length,
              itemBuilder: (context, index) {
                final variante = varianteProvider.variantes[index];
                final nombreProducto = variante.nombreProducto ?? 'Producto';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          _mostrarFormularioVariante(variante: variante),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado: Nombre del producto y Precio
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    nombreProducto,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${variante.precioVenta}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF6A1B29),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Subtítulo: SKU
                            Text(
                              'SKU: ${variante.sku}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: Color(0xFFF1F3F5),
                              ),
                            ),

                            // Ficha inferior: Mililitros, Stock y Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _InfoBadge(
                                      icon: Icons.water_drop_outlined,
                                      text: '${variante.mililitros ?? 0} ml',
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoBadge(
                                      icon: Icons.inventory_2_outlined,
                                      text: 'Stock: ${variante.stock}',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ActionIconButton(
                                      icon: Icons.edit_rounded,
                                      color: Colors.blue.shade700,
                                      bgColor: Colors.blue.shade50,
                                      onPressed: () =>
                                          _mostrarFormularioVariante(
                                            variante: variante,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    _ActionIconButton(
                                      icon: Icons.delete_rounded,
                                      color: Colors.red.shade700,
                                      bgColor: Colors.red.shade50,
                                      onPressed: () =>
                                          _confirmarEliminar(variante),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B29),
        elevation: 2,
        onPressed: () => _mostrarFormularioVariante(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<VarianteProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
