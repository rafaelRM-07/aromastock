import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/producto_detalle_provider.dart';
import '../widgets/common/detalles/detalle_header.dart';
import '../widgets/common/detalles/detalle_info_card.dart';
import '../widgets/common/detalles/variantes_list.dart';

class DetalleProductoView extends StatefulWidget {
  final int productoId;

  const DetalleProductoView({super.key, required this.productoId});

  @override
  State<DetalleProductoView> createState() => _DetalleProductoViewState();
}

class _DetalleProductoViewState extends State<DetalleProductoView> {
  @override
  void initState() {
    super.initState();
    // Carga el producto al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetalleProductoProvider>().cargarDetalle(widget.productoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetalleProductoProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalle del Perfume',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: (provider.cargando && provider.producto == null)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B29)),
            )
          : provider.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : provider.producto == null
          ? const Center(
              child: Text('No se encontró la información del producto.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header con foto, nombre y ocasión
                  DetalleHeaderWidget(producto: provider.producto!),

                  const SizedBox(height: 16),

                  // 2. Tarjeta con datos informativos del producto
                  DetalleInfoCardWidget(producto: provider.producto!),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 3. Lista de variantes vinculadas
                  VariantesListWidget(variantes: provider.producto!.variantes),
                ],
              ),
            ),
    );
  }
}
