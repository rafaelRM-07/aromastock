import 'package:supabase_flutter/supabase_flutter.dart';

class FiltrosDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  /// Obtiene la lista de marcas
  Future<List<Map<String, dynamic>>> getMarcas() async {
    final response = await _client
        .from('marcas')
        .select('id, nombre')
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Obtiene la lista de categorías
  Future<List<Map<String, dynamic>>> getCategorias() async {
    final response = await _client
        .from('categorias')
        .select('id, nombre')
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Obtiene la lista de concentraciones
  Future<List<Map<String, dynamic>>> getConcentraciones() async {
    final response = await _client
        .from('concentraciones')
        .select('id, nombre')
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Obtiene la lista de familias olfativas
  Future<List<Map<String, dynamic>>> getFamiliasOlfativas() async {
    final response = await _client
        .from('familias_olfativas')
        .select('id, nombre')
        .order('nombre');
    return List<Map<String, dynamic>>.from(response as List);
  }
}
