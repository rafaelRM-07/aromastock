import 'package:supabase_flutter/supabase_flutter.dart';

class EstadisticasDatabase {
  final _supabase = Supabase.instance.client;

  /// 1. Pedidos Despachados para Estadísticas
  Future<List<dynamic>> obtenerPedidosParaEstadisticas(
    DateTime? fechaInicio,
  ) async {
    var query = _supabase
        .from('pedidos')
        .select('''
      id,
      fecha,
      estado,
      pedido_detalles(
        cantidad,
        precio_unitario,
        variantes(
          id,
          sku,
          mililitros,
          productos(
            id,
            nombre,
            imagen_principal,
            familias_olfativas(nombre)
          )
        )
      )
    ''')
        .eq('estado', 'Despachado');

    if (fechaInicio != null) {
      query = query.gte('fecha', fechaInicio.toIso8601String());
    }

    return await query;
  }

  /// 2. Historial de Movimientos (Entradas / Salidas)
  Future<List<dynamic>> obtenerHistorialMovimientos(
    DateTime? fechaInicio,
  ) async {
    var query = _supabase.from('historial_movimientos').select('''
      id,
      tipo_movimiento,
      cantidad,
      fecha
    ''');

    if (fechaInicio != null) {
      query = query.gte('fecha', fechaInicio.toIso8601String());
    }

    return await query;
  }

  /// 3. Variantes con Stock y Marcas para Valor del Inventario
  Future<List<dynamic>> obtenerVariantesConMarcas() async {
    return await _supabase
        .from('variantes')
        .select('''
      id,
      stock,
      costo_compra,
      productos(
        marcas(nombre)
      )
    ''')
        .eq('activo', true);
  }
}
