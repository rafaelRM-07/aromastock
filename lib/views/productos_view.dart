import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/productos_model.dart';
import '../../data/providers/productos_provider.dart';
import '../widgets/common/catalogo/barra_busqueda.dart';
import '../widgets/common/catalogo/filtros.dart';
import '../widgets/common/catalogo/producto_card.dart';
import '../widgets/forms/productos_form.dart';
import 'package:aromastock/views/productos_detalle_view.dart';
import 'variantes_view.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final TextEditingController _searchController = TextEditingController();
  String _busquedaQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<ProductoProvider>();
        provider.cargarProductos();
        provider.initRealtime();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _busquedaQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    try {
      context.read<ProductoProvider>().stopRealtime();
    } catch (_) {}
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FiltrosBottomSheet(
          onAplicarFiltros: (filtros) {
            context.read<ProductoProvider>().aplicarFiltros(filtros);
          },
        );
      },
    );
  }

  void _mostrarFormularioProducto({ProductoModel? producto}) {
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 12,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(child: ProductoForm(producto: producto)),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(ProductoModel producto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}"?'),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (producto.id != null) {
                final provider = context.read<ProductoProvider>();
                final exito = await provider.eliminarProducto(producto.id!);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: exito
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content: Text(
                      exito
                          ? 'Producto eliminado correctamente'
                          : 'Error al eliminar el producto',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryWine = Color(0xFF4A1519);
    const Color softBackground = Color(0xFFF8F9FA);
    final productoProvider = context.watch<ProductoProvider>();

    final productosFiltrados = productoProvider.productos.where((p) {
      final nombre = p.nombre.toLowerCase();
      return nombre.contains(_busquedaQuery);
    }).toList();

    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera superior elegante tipo Dashboard
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catálogo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${productoProvider.productos.length} productos registrados',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 1. BARRA DE BÚSQUEDA Y BOTÓN DE FILTRO
            BarraBusquedaWidget(
              controller: _searchController,
              onFilterPressed: _mostrarFiltros,
            ),

            // 2. GRID DE PRODUCTOS
            Expanded(
              child:
                  (productoProvider.cargando &&
                      productoProvider.productos.isEmpty)
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryWine),
                      ),
                    )
                  : productosFiltrados.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _busquedaQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _busquedaQuery.isNotEmpty
                                  ? 'Sin coincidencias'
                                  : 'Inventario vacío',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _busquedaQuery.isNotEmpty
                                  ? 'No encontramos ningún producto con ese nombre.'
                                  : 'Comienza agregando tu primer producto al catálogo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      // SE APLICÓ PADDING INFERIOR DE 100 PARA QUE EL FAB NO TAPE LOS ÚLTIMOS PRODUCTOS
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index];

                        return ProductoCard(
                          producto: producto,
                          onTap: () {
                            if (producto.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleProductoView(
                                    productoId: producto.id!,
                                  ),
                                ),
                              );
                            }
                          },
                          onAgregarVariante: () {
                            if (producto.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VariantesView(
                                    productoId: producto.id!,
                                    abrirFormularioAlInicio: true,
                                  ),
                                ),
                              );
                            }
                          },
                          onEditar: () =>
                              _mostrarFormularioProducto(producto: producto),
                          onEliminar: () => _confirmarEliminar(producto),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // BOTÓN FLOTANTE CAMBIADO A CIRCULAR ESTÁNDAR
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryWine,
        elevation: 4,
        onPressed: () => _mostrarFormularioProducto(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
