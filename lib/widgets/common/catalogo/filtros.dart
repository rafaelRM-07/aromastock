import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/filtros_provider.dart';

class FiltrosBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAplicarFiltros;

  const FiltrosBottomSheet({super.key, required this.onAplicarFiltros});

  @override
  State<FiltrosBottomSheet> createState() => _FiltrosBottomSheetState();
}

class _FiltrosBottomSheetState extends State<FiltrosBottomSheet> {
  @override
  void initState() {
    super.initState();
    // CORRECCIÓN CLAVE AQUÍ:
    // Usamos addPostFrameCallback para asegurar que el contexto esté listo.
    // Llamamos a recargarCatalogosForzado() para que, aunque ya existan datos,
    // vaya a Supabase y traiga los nombres nuevos (ej. de Gucci a Prada).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si tu provider tiene el método que agregamos anteriormente, úsalo:
      context.read<FiltrosProvider>().recargarCatalogosForzado();

      // Si no modificaste el provider, usa la carga normal, pero asegúrate
      // que el provider no tenga la bandera de _catalogosCargados = true;
      // context.read<FiltrosProvider>().cargarCatalogos();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryWine = Color(0xFF4A1519);

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Usamos Consumer para escuchar los cambios de estado
      child: Consumer<FiltrosProvider>(
        builder: (context, provider, child) {
          // Mostramos indicador de carga mientras se consulta Supabase
          if (provider.isLoading) {
            return const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: primaryWine),
              ),
            );
          }

          // Mostramos error si ocurre
          if (provider.errorMessage != null) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Construimos la UI con los datos obtenidos
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar (indicador visual de arrastre)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtros Avanzados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    TextButton(
                      onPressed: () => provider.limpiarFiltros(),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // 1. Dropdown Marca
                _buildDropdown(
                  label: 'Marca',
                  value: provider.marcaIdSeleccionada,
                  items: provider.marcas, // Lista actualizada desde Supabase
                  onChanged: (id) => provider.seleccionarMarca(id),
                ),

                // 2. Dropdown Categoría
                _buildDropdown(
                  label: 'Categoría',
                  value: provider.categoriaIdSeleccionada,
                  items: provider.categorias,
                  onChanged: (id) => provider.seleccionarCategoria(id),
                ),

                // 3. Dropdown Concentración
                _buildDropdown(
                  label: 'Concentración',
                  value: provider.concentracionIdSeleccionada,
                  items: provider.concentraciones,
                  onChanged: (id) => provider.seleccionarConcentracion(id),
                ),

                // 4. Dropdown Familia Olfativa
                _buildDropdown(
                  label: 'Familia Olfativa',
                  value: provider.familiaOlfativaIdSeleccionada,
                  items: provider.familiasOlfativas,
                  onChanged: (id) => provider.seleccionarFamiliaOlfativa(id),
                ),

                const SizedBox(height: 20),

                // Botón Aplicar Filtros
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryWine,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Obtenemos el mapa de filtros seleccionados y cerramos
                      widget.onAplicarFiltros(provider.obtenerMapFiltros());
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Aplicar Filtros',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar para construir cada Dropdown
  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        // IMPORTANTE: Usar 'value' en lugar de 'initialValue' para reactividad
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // Mapeo de los datos de Supabase (Map<String, dynamic>) a DropdownMenuItem
        items: items.map((item) {
          // Asegurarnos que el ID sea entero
          final int itemId = item['id'] is int
              ? item['id']
              : int.parse(item['id'].toString());

          return DropdownMenuItem<int>(
            value: itemId,
            child: Text(
              item['nombre']?.toString() ?? '', // Muestra el nombre actualizado
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        // Se ejecuta al seleccionar una opción
        onChanged: onChanged,
      ),
    );
  }
}
