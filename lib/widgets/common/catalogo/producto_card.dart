import 'package:flutter/material.dart';
import '../../../data/models/productos_model.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onTap; // <--- Callback para ir a los detalles
  final VoidCallback onAgregarVariante;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    required this.onAgregarVariante,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ZONA CLICKEABLE: IMAGEN Y NOMBRE (Navega al detalle)
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // IMAGEN PRINCIPAL
                    Expanded(
                      child: Container(
                        color: Colors.grey[100],
                        child:
                            producto.imagenPrincipal != null &&
                                producto.imagenPrincipal!.isNotEmpty
                            ? Image.network(
                                producto.imagenPrincipal!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                      ),
                    ),

                    // NOMBRE DEL PRODUCTO
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. BOTONES DE ACCIÓN (Agregar Variante, Editar, Eliminar)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 6,
                left: 6,
                right: 6,
                top: 2,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF6A1B29),
                        size: 20,
                      ),
                      tooltip: 'Agregar Variante',
                      onPressed: onAgregarVariante,
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                      tooltip: 'Editar Producto',
                      onPressed: onEditar,
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: 'Eliminar Producto',
                      onPressed: onEliminar,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
