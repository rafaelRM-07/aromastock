import 'package:flutter/material.dart';

class FiltroTiempoWidget extends StatelessWidget {
  final String filtroSeleccionado; // 'Semanal', 'Mensual', 'Anual', 'Todo'
  final ValueChanged<String> onChanged;

  const FiltroTiempoWidget({
    super.key,
    required this.filtroSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryWine = Color(0xFF4A1519);
    final List<String> opciones = ['Semanal', 'Mensual', 'Anual', 'Todo'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filtros:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: opciones.map((opcion) {
                  final bool esSeleccionado =
                      filtroSeleccionado.toLowerCase() == opcion.toLowerCase();
                  final String labelTexto = opcion == 'Todo'
                      ? 'Todo el tiempo'
                      : opcion;

                  return GestureDetector(
                    onTap: () => onChanged(opcion),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: esSeleccionado
                            ? primaryWine
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: esSeleccionado
                            ? [
                                BoxShadow(
                                  color: primaryWine.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        labelTexto,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: esSeleccionado
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: esSeleccionado ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
