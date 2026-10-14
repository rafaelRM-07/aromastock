import 'package:flutter/material.dart';
import 'categorias_view.dart';
import 'marcas_view.dart';
import 'concentraciones_view.dart';
import 'familias_olfativas_view.dart';
import 'ubicaciones_view.dart';

class CatalogosView extends StatelessWidget {
  const CatalogosView({super.key});

  final List<Map<String, dynamic>> _catalogos = const [
    {
      'title': 'Categorías',
      'icon': Icons.category_rounded,
      'view': CategoriasView(),
    },
    {
      'title': 'Marcas',
      'icon': Icons.branding_watermark_rounded,
      'view': MarcasView(),
    },
    {
      'title': 'Concentraciones',
      'icon': Icons.science_rounded,
      'view': ConcentracionesView(),
    },
    {
      'title': 'Familias Olf.',
      'icon': Icons.spa_rounded,
      'view': FamiliasOlfativasView(),
    },

    {
      'title': 'Ubicaciones',
      'icon': Icons.location_on_rounded,
      'view': UbicacionesView(),
    },
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text("Catálogos"),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF6A1B29),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        // REGLA DE ORO: Siempre usar pop, NUNCA pushReplacement aquí
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _catalogos.length,
      itemBuilder: (context, index) {
        final item = _catalogos[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['view']),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 28, color: const Color(0xFF6A1B29)),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item['status'] ?? '',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
