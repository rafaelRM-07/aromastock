import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/metricas_provider.dart';

class DashboardCardsWidget extends StatelessWidget {
  const DashboardCardsWidget({super.key});

  String _formatearMonto(double monto) {
    if (monto >= 1000000) {
      return '\$${(monto / 1000000).toStringAsFixed(1)}M';
    } else if (monto >= 1000) {
      return '\$${(monto / 1000).toStringAsFixed(1)}k';
    } else {
      return '\$${monto.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MetricsProvider>(
      builder: (context, provider, child) {
        if (provider.cargando && !provider.hasLoaded) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final m = provider.metrics;

        return Row(
          children: [
            // Card 1: Venta Total
            Expanded(
              child: _MetricCard(
                titulo: 'Venta Total\nStock',
                valor: _formatearMonto(m.ventaTotal),
                colorValor: const Color(0xFF388E3C), // Verde
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Perfumes Activos
            Expanded(
              child: _MetricCard(
                titulo: 'Perfumes\nActivos',
                valor: m.perfumesActivos.toString(),
                colorValor: const Color(0xFF1D1BFF), // Azul
              ),
            ),
            const SizedBox(width: 10),

            // Card 3: Alertas de Stock Bajo
            Expanded(
              child: _MetricCard(
                titulo: 'Alertas de\nStock Bajo',
                valor: m.alertasStockBajo.toString(),
                colorValor: const Color(0xFFD32F2F), // Rojo
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color colorValor;

  const _MetricCard({
    required this.titulo,
    required this.valor,
    required this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorValor,
            ),
          ),
        ],
      ),
    );
  }
}
