import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductoDatabase {
  final _client = Supabase.instance.client;
  final String _bucketName = 'images';
  final String _folderName = 'perfumes';

  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await _client
        .from('productos')
        .select('*, variantes(*), galerias(*)')
        .order('id', ascending: false);
  }

  // En ProductoDatabase.dart
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    return await _client.from('productos').insert(data).select().single();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _client.from('productos').update(data).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _client.from('productos').delete().eq('id', id);
  }

  Future<String> uploadImage(File file) async {
    final rawName = file.path.split(RegExp(r'[/\\]')).last;
    final sanitizedName = rawName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    final path = '$_folderName/$fileName';

    final bytes = await file.readAsBytes();

    await _client.storage
        .from(_bucketName)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _client.storage.from(_bucketName).getPublicUrl(path);
  }

  //
  Future<List<Map<String, dynamic>>> fetchConFiltros(
    Map<String, dynamic> filtros,
  ) async {
    // 1. Iniciamos la consulta base
    var query = _client.from('productos').select('*');

    // 2. Evaluamos estricta y únicamente los IDs que NO sean nulos
    if (filtros['marca_id'] != null) {
      query = query.eq('marca_id', filtros['marca_id']);
    }

    if (filtros['categoria_id'] != null) {
      query = query.eq('categoria_id', filtros['categoria_id']);
    }

    if (filtros['concentracion_id'] != null) {
      query = query.eq('concentracion_id', filtros['concentracion_id']);
    }

    if (filtros['familia_olfativa_id'] != null) {
      query = query.eq('familia_olfativa_id', filtros['familia_olfativa_id']);
    }

    // 3. Ejecutamos la consulta filtrada
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
}
