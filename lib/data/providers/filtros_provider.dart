import 'package:flutter/material.dart';
import '../repository/filtros_repository.dart';

class FiltrosProvider extends ChangeNotifier {
  final FiltrosRepository _repository = FiltrosRepository();

  List<Map<String, dynamic>> _marcas = [];
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _concentraciones = [];
  List<Map<String, dynamic>> _familiasOlfativas = [];

  bool _isLoading = false;
  bool _catalogosCargados = false; // Bandera para evitar peticiones múltiples
  String? _errorMessage;

  // Filtros seleccionados actualmente (guardan los ID de la BD)
  int? marcaIdSeleccionada;
  int? categoriaIdSeleccionada;
  int? concentracionIdSeleccionada;
  int? familiaOlfativaIdSeleccionada;

  // Getters
  List<Map<String, dynamic>> get marcas => _marcas;
  List<Map<String, dynamic>> get categorias => _categorias;
  List<Map<String, dynamic>> get concentraciones => _concentraciones;
  List<Map<String, dynamic>> get familiasOlfativas => _familiasOlfativas;
  bool get isLoading => _isLoading;
  bool get catalogosCargados => _catalogosCargados;
  String? get errorMessage => _errorMessage;

  /// Carga los catálogos desde Supabase de forma segura una sola vez
  Future<void> cargarCatalogos() async {
    // Si ya se cargaron o están cargando actualmente, no hacemos nada
    if (_catalogosCargados || _isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final catalogos = await _repository.obtenerCatalogosFiltros();

      _marcas = catalogos['marcas'] ?? [];
      _categorias = catalogos['categorias'] ?? [];
      _concentraciones = catalogos['concentraciones'] ?? [];
      _familiasOlfativas =
          catalogos['familias'] ?? []; // Coincide con el repositorio

      _catalogosCargados = true;
    } catch (e) {
      _errorMessage = 'Error al cargar las opciones de filtro.';
      debugPrint('Error en cargarCatalogos: $e');
      _catalogosCargados = false; // Permite reintentar si falla
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void seleccionarMarca(int? id) {
    marcaIdSeleccionada = id;
    notifyListeners();
  }

  void seleccionarCategoria(int? id) {
    categoriaIdSeleccionada = id;
    notifyListeners();
  }

  void seleccionarConcentracion(int? id) {
    concentracionIdSeleccionada = id;
    notifyListeners();
  }

  void seleccionarFamiliaOlfativa(int? id) {
    familiaOlfativaIdSeleccionada = id;
    notifyListeners();
  }

  void limpiarFiltros() {
    marcaIdSeleccionada = null;
    categoriaIdSeleccionada = null;
    concentracionIdSeleccionada = null;
    familiaOlfativaIdSeleccionada = null;
    notifyListeners();
  }

  /// Devuelve la estructura de filtros lista para hacer consultas en Supabase
  Map<String, dynamic> obtenerMapFiltros() {
    return {
      'marca_id': marcaIdSeleccionada,
      'categoria_id': categoriaIdSeleccionada,
      'concentracion_id': concentracionIdSeleccionada,
      'familia_olfativa_id': familiaOlfativaIdSeleccionada,
    };
  }

  /// Fuerza la recarga de catálogos ignorando la caché (útil si hubo cambios en BD)
  Future<void> recargarCatalogosForzado() async {
    _catalogosCargados = false;
    await cargarCatalogos();
  }
}
