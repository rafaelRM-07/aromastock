import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/supabase_config.dart';

class SupabaseService {
  // Inicialización global del cliente
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  // Referencia al cliente para usar en toda la app
  static SupabaseClient get client => Supabase.instance.client;
}
