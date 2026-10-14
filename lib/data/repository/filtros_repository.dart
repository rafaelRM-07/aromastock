import '../database/supabase/filtros_database.dart';

class FiltrosRepository {
  final FiltrosDatabase _database = FiltrosDatabase();

  /// Carga todos los catálogos de filtros de forma simultánea
  Future<Map<String, List<Map<String, dynamic>>>>
  obtenerCatalogosFiltros() async {
    final resultados = await Future.wait([
      _database.getMarcas(),
      _database.getCategorias(),
      _database.getConcentraciones(),
      _database.getFamiliasOlfativas(),
    ]);

    return {
      'marcas': resultados[0],
      'categorias': resultados[1],
      'concentraciones': resultados[2],
      'familias': resultados[3],
    };
  }
}
