import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/productos_model.dart';
import '../repository/productos_repository.dart';

class ProductoProvider extends ChangeNotifier {
  final _repository = ProductoRepository();

  List<ProductoModel> _productos = [];
  bool _cargando = false;
  String? _error;

  RealtimeChannel? _channel;

  List<ProductoModel> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Carga inicial o recarga de productos.
  /// Si ya hay datos en memoria, la recarga será silenciosa (no activa el flag _cargando)
  Future<void> cargarProductos() async {
    final bool wasEmpty = _productos.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }

    try {
      _productos = await _repository.listar();
    } catch (e) {
      _error = 'Error al cargar productos: $e';
    } finally {
      if (wasEmpty) {
        _cargando = false;
      }
      notifyListeners();
    }
  }

  // CREAR: no forzar indicador global de carga si ya existen datos
  Future<ProductoModel?> crearProducto(
    ProductoModel producto,
    File? imagenFile,
  ) async {
    _error = null;
    notifyListeners(); // permite a la UI limpiar errores previos
    try {
      final nuevoProd = await _repository.crear(producto, imagenFile);
      // Refresco silencioso si ya teníamos datos
      await _refreshProductosSilently();
      return nuevoProd;
    } catch (e) {
      _error = 'Error al crear producto: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> editarProducto(ProductoModel producto, File? nuevaImagen) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.actualizar(producto, nuevaImagen);
      await _refreshProductosSilently();
      return true;
    } catch (e) {
      _error = 'Error al editar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      await _repository.eliminar(id);
      await _refreshProductosSilently();
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> aplicarFiltros(Map<String, dynamic> filtros) async {
    final bool wasEmpty = _productos.isEmpty;
    if (wasEmpty) {
      _cargando = true;
      notifyListeners();
    }
    try {
      _productos = await _repository.filtrar(filtros);
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners(); // Notifica a la pantalla principal
    }
  }

  // Refresco en segundo plano sin activar el indicador global de carga
  Future<void> _refreshProductosSilently() async {
    try {
      final lista = await _repository.listar();
      _productos = lista;
      notifyListeners();
    } catch (_) {
      // Se ignoran errores en refrescos silenciosos para no romper la UI
    }
  }

  /// Inicializa la suscripción Realtime para la tabla 'productos'.
  /// Llamar desde el initState de la vista que use este provider.
  void initRealtime() {
    if (_channel != null) return;

    _channel = Supabase.instance.client
        .channel('public:productos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'productos',
          callback: (payload) async {
            final bool wasEmpty = _productos.isEmpty;
            if (wasEmpty) {
              _cargando = true;
              notifyListeners();
            }

            try {
              _productos = await _repository.listar();
            } catch (_) {
              // Ignorar para no sobrecargar la UI
            } finally {
              if (wasEmpty) _cargando = false;
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  /// Cancela la suscripción Realtime (evitar fugas de memoria)
  Future<void> _unsubscribeRealtime() async {
    if (_channel == null) return;
    try {
      await _channel!.unsubscribe();
    } catch (_) {
      try {
        Supabase.instance.client.removeChannel(_channel!);
      } catch (_) {}
    }
    _channel = null;
  }

  /// Stop realtime subscription from external callers (e.g., views)
  Future<void> stopRealtime() async => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }
}
