import 'productos_model.dart';
import 'variante_model.dart'; // <--- Importas tu modelo existente de variantes

class DetalleProductoModel {
  final ProductoModel producto;
  final List<VarianteModel> variantes;

  DetalleProductoModel({required this.producto, required this.variantes});
}
