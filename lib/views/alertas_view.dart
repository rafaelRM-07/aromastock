import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/alerta_provider.dart';
import '../../widgets/common/alertas/alertas_card.dart';

class AlertasView extends StatefulWidget {
  const AlertasView({super.key});

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AlertaProvider>();
      provider.cargarAlertas();
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
          'Alertas de Stock',
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
      body: Consumer<AlertaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.alertas.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryWine),
                strokeWidth: 2.5,
              ),
            );
          }

          final productosCriticos = provider.alertas.where((alerta) {
            return alerta.stockActual <= 15;
          }).toList();

          if (productosCriticos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 36,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Todo en orden!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No hay productos con stock crítico en este momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de sección y contador dinámico
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Inventario Crítico',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${productosCriticos.length} ${productosCriticos.length == 1 ? 'producto' : 'productos'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de tarjetas
              Expanded(
                child: RefreshIndicator(
                  color: primaryWine,
                  backgroundColor: Colors.white,
                  onRefresh: () => provider.cargarAlertas(),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: productosCriticos.length,
                    itemBuilder: (context, index) {
                      return AlertaExpandableCard(
                        alerta: productosCriticos[index],
                      );
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
      context.read<AlertaProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}
