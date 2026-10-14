import 'dart:io';
import '../database/supabase/productos_database.dart';
import '../models/productos_model.dart';

class ProductoRepository {
  final _db = ProductoDatabase();

  Future<List<ProductoModel>> listar() async {
    final data = await _db.fetchAll();
    return data.map((json) => ProductoModel.fromJson(json)).toList();
  }

  // En ProductoRepository.dart
  Future<ProductoModel> crear(ProductoModel producto, File? imagenFile) async {
    String? urlImagen = producto.imagenPrincipal;
    if (imagenFile != null) {
      urlImagen = await _db.uploadImage(imagenFile);
    }

    final mapa = producto.toJson();

    // Limpiamos llaves de relaciones antes de enviar a la tabla 'productos'
    mapa.remove('id');
    mapa.remove('variantes');
    mapa.remove('galerias');
    mapa['imagen_principal'] = urlImagen;

    final response = await _db.insert(mapa);
    return ProductoModel.fromJson(response);
  }

  Future<void> actualizar(ProductoModel producto, File? nuevaImagenFile) async {
    if (producto.id == null) throw Exception("ID requerido para actualizar");

    String? urlImagen = producto.imagenPrincipal;
    if (nuevaImagenFile != null) {
      urlImagen = await _db.uploadImage(nuevaImagenFile);
    }

    final mapa = producto.toJson();
    mapa['imagen_principal'] = urlImagen;
    await _db.update(producto.id!, mapa);
  }

  Future<void> eliminar(int id) async {
    await _db.delete(id);
  }

  Future<List<ProductoModel>> filtrar(Map<String, dynamic> filtros) async {
    final data = await _db.fetchConFiltros(filtros);
    return data.map((json) => ProductoModel.fromJson(json)).toList();
  }
}
