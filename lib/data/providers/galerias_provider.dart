import 'dart:io';
import 'package:flutter/material.dart';
import '../models/galeria_model.dart';
import '../repository/galerias_repository.dart';

class GaleriaProvider extends ChangeNotifier {
  final _repository = GaleriaRepository();

  List<GaleriaModel> _imagenes = [];
  bool _cargando = false;

  List<GaleriaModel> get imagenes => _imagenes;
  bool get cargando => _cargando;

  Future<void> cargarPorProducto(int productoId) async {
    _cargando = true;
    notifyListeners();
    try {
      _imagenes = await _repository.listarPorProducto(productoId);
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> subirImagen(int productoId, File archivo) async {
    _cargando = true;
    notifyListeners();
    try {
      await _repository.subirEInsertar(productoId, archivo);
      await cargarPorProducto(productoId);
      return true;
    } catch (e) {
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> borrarImagen(int galeriaId, int productoId) async {
    try {
      await _repository.eliminar(galeriaId);
      await cargarPorProducto(productoId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
