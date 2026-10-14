import 'package:supabase_flutter/supabase_flutter.dart';

class AlertasDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  /// Obtiene las alertas de stock configuradas junto con el stock de sus variantes activas
  Future<List<Map<String, dynamic>>> getAlertasStock() async {
    final response = await _client.from('alertas_stock').select('''
      id,
      variante_id,
      stock_minimo,
      variantes!inner (
        id,
        stock,
        mililitros,
        productos (
          id,
          nombre,
          imagen_principal
        )
      )
    ''');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Actualiza el stock de una variante específica directamente en la tabla variantes
  Future<void> updateStockVariante(int varianteId, int nuevoStock) async {
    await _client
        .from('variantes')
        .update({'stock': nuevoStock})
        .eq('id', varianteId);
  }
}
