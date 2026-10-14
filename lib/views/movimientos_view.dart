import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/movimiento_model.dart';
import '../../../data/providers/movimiento_provider.dart';
import '../widgets/common/movimientos/filtro_movimientos.dart';

class MovimientosView extends StatefulWidget {
  const MovimientosView({super.key});

  @override
  State<MovimientosView> createState() => _MovimientosViewState();
}

class _MovimientosViewState extends State<MovimientosView> {
  String _filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovimientoProvider>();
      provider.cargarHistorial();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Historial de Movimientos',
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
      body: Consumer<MovimientoProvider>(
        builder: (context, provider, child) {
          // Solo muestra el loader global si no hay ningún movimiento cargado previamente en memoria
          if (provider.isLoading && provider.movimientos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A1519)),
            );
          }

          if (provider.errorMessage != null && provider.movimientos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.cargarHistorial(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Filtrado en memoria
          final movimientosFiltrados = provider.movimientos.where((mov) {
            if (_filtroSeleccionado == 'Entradas') {
              return mov.tipoMovimiento == 'Entrada';
            } else if (_filtroSeleccionado == 'Salidas') {
              return mov.tipoMovimiento == 'Salida';
            } else if (_filtroSeleccionado == 'Ajuste') {
              return mov.tipoMovimiento == 'Ajuste';
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Barra de Filtros
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FiltroTipoMovimientoWidget(
                    filtroSeleccionado: _filtroSeleccionado,
                    onChanged: (nuevoFiltro) {
                      setState(() {
                        _filtroSeleccionado = nuevoFiltro;
                      });
                    },
                  ),
                ),
              ),

              // Lista de Movimientos con RefreshIndicator Global
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.cargarHistorial();
                  },
                  color: const Color(0xFF4A1519),
                  child: movimientosFiltrados.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  _filtroSeleccionado == 'Todos'
                                      ? 'No hay historial registrado.'
                                      : 'No hay movimientos de tipo "$_filtroSeleccionado".',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: movimientosFiltrados.length,
                          itemBuilder: (context, index) {
                            final item = movimientosFiltrados[index];
                            return _MovimientoExpandibleCard(movimiento: item);
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
      context.read<MovimientoProvider>().stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}

class _MovimientoExpandibleCard extends StatelessWidget {
  final MovimientoModel movimiento;

  const _MovimientoExpandibleCard({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final bool esEntrada = movimiento.tipoMovimiento == 'Entrada';
    final bool esAjuste = movimiento.tipoMovimiento == 'Ajuste';

    final Color colorTipo = esEntrada
        ? const Color(0xFF2ECC71)
        : esAjuste
        ? Colors.orange
        : const Color(0xFFE74C3C);

    final String prefijo = esEntrada
        ? '+'
        : esAjuste
        ? ''
        : '-';

    final String fechaFormateada = DateFormat(
      'dd/MM/yyyy - hh:mm a',
    ).format(movimiento.fecha);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: colorTipo.withValues(alpha: 0.12),
              child: Icon(
                esEntrada
                    ? Icons.arrow_downward
                    : esAjuste
                    ? Icons.tune
                    : Icons.arrow_upward,
                size: 18,
                color: colorTipo,
              ),
            ),
            title: Text(
              movimiento.nombrePerfume ?? 'Producto #${movimiento.varianteId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '${movimiento.tipoMovimiento}${movimiento.nombreVariante != null ? ' • ${movimiento.nombreVariante}' : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              '$prefijo${movimiento.cantidad}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorTipo,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    _buildFilaDetalle('ID Registro:', '#${movimiento.id}'),
                    _buildFilaDetalle('Fecha y Hora:', fechaFormateada),
                    if (movimiento.costoHistorico != null)
                      _buildFilaDetalle(
                        'Costo Histórico:',
                        '\$${movimiento.costoHistorico!.toStringAsFixed(2)} MXN',
                      ),
                    if (movimiento.motivo != null &&
                        movimiento.motivo!.isNotEmpty)
                      _buildFilaDetalle('Motivo:', movimiento.motivo!),
                    if (movimiento.perfilId != null)
                      _buildFilaDetalle('Perfil ID:', movimiento.perfilId!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilaDetalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
