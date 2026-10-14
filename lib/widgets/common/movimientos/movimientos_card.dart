import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/movimiento_provider.dart';

class MovimientosCard extends StatelessWidget {
  const MovimientosCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos Movimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<MovimientoProvider>(
            builder: (context, provider, child) {
              // Usamos isLoading si definiste la propiedad con ese nombre
              if (provider.isLoading && provider.movimientos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A1519)),
                  ),
                );
              }

              // Si usas un getter específico para el Dashboard o tomas los primeros 5
              final listaResumen = provider.movimientos.take(5).toList();

              if (listaResumen.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No hay movimientos recientes.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listaResumen.length,
                separatorBuilder: (context, index) => const Divider(height: 14),
                itemBuilder: (context, index) {
                  final mov = listaResumen[index];
                  final bool esEntrada = mov.tipoMovimiento == 'Entrada';
                  final bool esAjuste = mov.tipoMovimiento == 'Ajuste';

                  final Color colorIcono = esEntrada
                      ? const Color(0xFF2ECC71)
                      : esAjuste
                      ? Colors.orange
                      : const Color(0xFFE74C3C);

                  // Definición clara del prefijo según el tipo de movimiento
                  final String prefijo = esEntrada
                      ? '+'
                      : esAjuste
                      ? ''
                      : '-';

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorIcono.withValues(alpha: 0.12),
                        child: Icon(
                          esEntrada
                              ? Icons.arrow_downward
                              : esAjuste
                              ? Icons.tune
                              : Icons.arrow_upward,
                          size: 16,
                          color: colorIcono,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mov.nombrePerfume ??
                                  'Producto #${mov.varianteId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${mov.tipoMovimiento}${mov.nombreVariante != null ? ' • ${mov.nombreVariante}' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$prefijo${mov.cantidad}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorIcono,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
