import '../database/supabase/producto_detalle_database.dart';
import '../models/productos_model.dart'; // Tu archivo de ProductoModel

class DetalleProductoRepository {
  final DetalleProductoDatabase _db = DetalleProductoDatabase();

  Future<ProductoModel?> obtenerDetalleCompleto(int productoId) async {
    final data = await _db.getProductoConVariantes(productoId);
    if (data == null) return null;

    // Tu fromJson mapea automáticamente los campos del producto y su lista de variantes
    return ProductoModel.fromJson(data);
  }
}
