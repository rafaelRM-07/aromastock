import 'package:flutter/material.dart';
import '../models/productos_model.dart';
import '../repository/producto_detalle_repository.dart';

class DetalleProductoProvider extends ChangeNotifier {
  final DetalleProductoRepository _repository = DetalleProductoRepository();

  ProductoModel? _producto;
  bool _cargando = false;
  bool _hasLoaded = false;
  String? _error;

  ProductoModel? get producto => _producto;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarDetalle(int productoId) async {
    final bool wasEmpty = !_hasLoaded;
    if (wasEmpty) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }

    try {
      _producto = await _repository.obtenerDetalleCompleto(productoId);
      _hasLoaded = true;
    } catch (e) {
      _error = 'Error al cargar el detalle del producto: $e';
    } finally {
      if (wasEmpty) _cargando = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _producto = null;
    _error = null;
    _cargando = false;
    _hasLoaded = false;
  }
}
