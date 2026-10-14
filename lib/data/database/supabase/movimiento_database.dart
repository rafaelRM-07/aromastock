import 'package:supabase_flutter/supabase_flutter.dart';

class MovimientoDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  /// Consulta el historial de movimientos ordenado por fecha
  Future<List<Map<String, dynamic>>> fetchTodoElHistorial() async {
    try {
      final response = await _client
          .from('historial_movimientos')
          .select('''
            *,
            variantes (
              id,
              sku,
              mililitros,
              productos (
                nombre
              )
            )
          ''')
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener todo el historial: $e');
    }
  }

  /// Inserta un nuevo registro en el historial
  Future<void> insertMovimiento(Map<String, dynamic> data) async {
    try {
      await _client.from('historial_movimientos').insert(data);
    } catch (e) {
      throw Exception('Error al registrar movimiento: $e');
    }
  }

  /// Consulta movimientos filtrados por variante concreta
  Future<List<Map<String, dynamic>>> fetchMovimientosPorVariante(
    int varianteId,
  ) async {
    try {
      final response = await _client
          .from('historial_movimientos')
          .select('''
            *,
            variantes (
              id,
              sku,
              mililitros,
              productos (
                nombre
              )
            )
          ''')
          .eq('variante_id', varianteId)
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al consultar movimientos por variante: $e');
    }
  }
}
