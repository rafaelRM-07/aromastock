import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/pedido_provider.dart';
import '../../widgets/common/pedidos/filtro_pedidos.dart';
import '../../widgets/common/pedidos/pedido_card.dart'; // Asegúrate que apunte a tu componente renovado

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  String _filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PedidoProvider>();
      provider.cargarPedidos();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryWine = Color(0xFF4A1519);
    const Color softBackground = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Consumer<PedidoProvider>(
        builder: (context, provider, child) {
          // Spinner inicial elegante solo si está cargando Y la lista local está vacía
          if (provider.isLoading && provider.pedidos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryWine),
                strokeWidth: 2.5,
              ),
            );
          }

          // Estado de error rediseñado
          if (provider.errorMessage != null && provider.pedidos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Ocurrió un problema!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryWine,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => provider.cargarPedidos(),
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filtrado en memoria de los pedidos según el filtro activo
          final pedidosFiltrados = provider.pedidos.where((pedido) {
            if (_filtroEstado == 'Todos') return true;
            return pedido.estado.toLowerCase() == _filtroEstado.toLowerCase();
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Barra de filtros horizontal limpia
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FiltroPedido(
                  filtroSeleccionado: _filtroEstado,
                  onChanged: (nuevoEstado) {
                    setState(() {
                      _filtroEstado = nuevoEstado;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Lista principal de pedidos con soporte Pull-To-Refresh
              Expanded(
                child: pedidosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _filtroEstado == 'Todos'
                                  ? 'No hay pedidos registrados.'
                                  : 'No hay pedidos con el estado "$_filtroEstado".',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: primaryWine,
                        backgroundColor: Colors.white,
                        onRefresh: () => provider.cargarPedidos(),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: pedidosFiltrados.length,
                          itemBuilder: (context, index) {
                            final pedido = pedidosFiltrados[index];
                            return PedidoExpandableCard(pedido: pedido);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<PedidoProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}
