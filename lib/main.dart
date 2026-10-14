import 'package:flutter/material.dart';
import 'package:aromastock/app.dart';
import 'package:provider/provider.dart';
//DATABASE
import 'package:aromastock/data/services/supabase_service.dart';

//PROVIDERS
//import 'package:aromastock/data/providers/productos_provider.dart';
import 'package:aromastock/data/providers/auth_provider.dart';
import 'package:aromastock/data/providers/categoria_provider.dart';
import 'package:aromastock/data/providers/concentraciones_provider.dart';
import 'package:aromastock/data/providers/marcas_provider.dart';
import 'package:aromastock/data/providers/familia_olfativa_provider.dart';
import 'package:aromastock/data/providers/ubicacion_provider.dart';
import 'package:aromastock/data/providers/proveedor_provider.dart';
import 'package:aromastock/data/providers/variantes_provider.dart';
import 'package:aromastock/data/providers/productos_provider.dart';
import 'package:aromastock/data/providers/galerias_provider.dart';
import 'package:aromastock/data/providers/estadisticas_provider.dart';
import 'package:aromastock/data/providers/movimiento_provider.dart';
import 'package:aromastock/data/providers/pedido_provider.dart';
import 'package:aromastock/data/providers/alerta_provider.dart';
import 'package:aromastock/data/providers/metricas_provider.dart';
import 'package:aromastock/data/providers/filtros_provider.dart';
import 'package:aromastock/data/providers/producto_detalle_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await LocalDatabase.instance.database;
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      //Providers para toda la app
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => ConcentracionProvider()),
        ChangeNotifierProvider(create: (_) => MarcaProvider()),
        ChangeNotifierProvider(create: (_) => FamiliaOlfativaProvider()),
        ChangeNotifierProvider(create: (_) => UbicacionProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
        ChangeNotifierProvider(create: (_) => VarianteProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => GaleriaProvider()),
        ChangeNotifierProvider(create: (_) => EstadisticasProvider()),
        ChangeNotifierProvider(create: (_) => MovimientoProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => AlertaProvider()),
        ChangeNotifierProvider(create: (_) => FiltrosProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
        ChangeNotifierProvider(create: (_) => DetalleProductoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
