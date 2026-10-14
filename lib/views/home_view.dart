import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Componentes modulares
import 'package:aromastock/widgets/common/dashboard/kpi_card.dart';
import '../widgets/common/dashboard/quick_action_button.dart';
import '../widgets/common/movimientos/movimientos_card.dart';
import '../widgets/common/estadisticas/grafica_resumen_dashboard.dart';

// Providers
import '../data/providers/movimiento_provider.dart';
import '../data/providers/metricas_provider.dart';
import '../data/providers/estadisticas_provider.dart';

// Vistas
import 'alertas_view.dart';
import 'pedidos_view.dart';
import 'movimientos_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosGenerales();
    });
  }

  /// Método centralizado para solicitar recarga a todos los providers de la Dashboard
  Future<void> _cargarDatosGenerales() async {
    final metricsProvider = context.read<MetricsProvider>();
    final movimientoProvider = context.read<MovimientoProvider>();
    final estadisticasProvider = context.read<EstadisticasProvider>();

    // Ejecuta las peticiones de refresco en paralelo para mejor rendimiento
    await Future.wait([
      metricsProvider.cargarMetricas(),
      movimientoProvider.cargarHistorial(),
      estadisticasProvider.cargarEstadisticas(),
    ]);

    // Asegura la suscripción en tiempo real por si fue interrumpida
    metricsProvider.initRealtime();
    movimientoProvider.initRealtime();
    estadisticasProvider.initRealtime();
  }

  @override
  void dispose() {
    try {
      context.read<MetricsProvider>().stopRealtime();
      context.read<MovimientoProvider>().stopRealtime();
      context.read<EstadisticasProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryWine = Color(0xFF4A1519);
    const Color softBackground = Color(0xFFF4F4F6);

    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryWine,
          onRefresh: _cargarDatosGenerales,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sección de KPIs con datos en vivo
                const DashboardCardsWidget(),

                const SizedBox(height: 25),

                // 2. Gráfica de Flujo de Actividad y Accesos Rápidos
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- GRÁFICA DE ACTIVIDAD (ENTRADAS VS SALIDAS) ---
                      const Expanded(
                        flex: 11,
                        child: GraficaActividadDashboardWidget(),
                      ),

                      const SizedBox(width: 15),

                      // --- BOTONES DE ACCIÓN RÁPIDA ---
                      Expanded(
                        flex: 9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            QuickActionButton(
                              icon: Icons.notifications_none_outlined,
                              label: 'Alertas',
                              color: primaryWine,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AlertasView(),
                                ),
                              ),
                            ),
                            QuickActionButton(
                              icon: Icons.inventory_2_outlined,
                              label: 'Pedidos',
                              color: primaryWine,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PedidosView(),
                                ),
                              ),
                            ),
                            QuickActionButton(
                              icon: Icons.history,
                              label: 'Historial',
                              color: primaryWine,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MovimientosView(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. Tarjeta de Movimientos Recientes
                const MovimientosCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
