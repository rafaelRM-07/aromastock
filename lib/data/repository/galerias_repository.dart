import 'dart:io';
import '../database/supabase/galerias_database.dart';
import '../database/supabase/productos_database.dart';
import '../models/galeria_model.dart';

class GaleriaRepository {
  final _dbGaleria = GaleriaDatabase();
  final _dbProducto =
      ProductoDatabase(); // Para reutilizar el método uploadImage

  Future<List<GaleriaModel>> listarPorProducto(int productoId) async {
    final data = await _dbGaleria.fetchByProducto(productoId);
    return data.map((json) => GaleriaModel.fromJson(json)).toList();
  }

  Future<void> subirEInsertar(int productoId, File archivoImagen) async {
    final url = await _dbProducto.uploadImage(archivoImagen);
    final galeria = GaleriaModel(productoId: productoId, rutaImagen: url);
    await _dbGaleria.insert(galeria.toJson());
  }

  Future<void> eliminar(int id) async {
    await _dbGaleria.delete(id);
  }
}
