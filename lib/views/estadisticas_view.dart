import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/estadisticas_provider.dart';

import '../widgets/common/estadisticas/filtro_estadisticas.dart';
import '../widgets/common/estadisticas/ranking_top10.dart';
import '../widgets/common/estadisticas/grafica_familias.dart';
import '../widgets/common/estadisticas/grafica_menos_vendidas.dart';
import '../widgets/common/estadisticas/grafica_flujo_movimientos.dart';
import '../widgets/common/estadisticas/grafica_top_marcas.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({super.key});

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EstadisticasProvider>();
      provider.cargarEstadisticas();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstadisticasProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TÍTULO SIMPLE (Sin AppBar)
              const Text(
                'Estadísticas y Reportes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A1519),
                ),
              ),
              const SizedBox(height: 20),

              // FILTRO DE TIEMPO
              Center(
                child: FiltroTiempoWidget(
                  filtroSeleccionado: provider.filtroTiempo,
                  onChanged: (nuevo) {
                    provider.cambiarFiltroTiempo(nuevo);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 1. TARJETA VENTAS TOTALES
              _buildTarjetaContenedora(
                titulo: 'Ventas Totales',
                child: Text(
                  '\$${provider.reporte?.totalVentas.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A1519),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. FLUJO ENTRADAS VS SALIDAS
              _buildTarjetaContenedora(
                titulo: 'Flujo de Entradas vs Salidas',
                child: GraficaFlujoMovimientosWidget(
                  datos: provider.reporte?.flujoMovimientos ?? [],
                ),
              ),
              const SizedBox(height: 16),

              // 3. TOP MARCAS POR VALOR
              _buildTarjetaContenedora(
                titulo: 'Top Marcas por Valor Monetario en Almacén',
                child: GraficaTopMarcasWidget(
                  datos: provider.reporte?.topMarcasValor ?? [],
                ),
              ),
              const SizedBox(height: 16),

              // 4. RANKING TOP 10 MÁS VENDIDOS
              _buildTarjetaContenedora(
                titulo: 'Top 10 Fragancias Más Vendidas',
                child: RankingTop10Widget(
                  listaTop: provider.reporte?.top10MasVendidos ?? [],
                ),
              ),
              const SizedBox(height: 16),

              // 5. FAMILIAS OLFATIVAS
              _buildTarjetaContenedora(
                titulo: 'Familias Olfativas Más Vendidas',
                child: GraficaFamiliasWidget(
                  datos: provider.reporte?.familiasMasVendidas ?? [],
                ),
              ),
              const SizedBox(height: 16),

              // 6. FRAGANCIAS MENOS VENDIDAS
              _buildTarjetaContenedora(
                titulo: 'Fragancias Menos Vendidas',
                child: GraficaMenosVendidasWidget(
                  datos: provider.reporte?.fraganciasMenosVendidas ?? [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaContenedora({
    required String titulo,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<EstadisticasProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}
