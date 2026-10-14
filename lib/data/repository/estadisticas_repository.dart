import '../database/supabase/estadisticas_database.dart';
import '../models/estadistica_model.dart';

class EstadisticasRepository {
  final EstadisticasDatabase _db = EstadisticasDatabase();

  Future<ReporteVentasModel> obtenerReporteGeneral(String filtroTiempo) async {
    final DateTime? fechaInicio = _calcularFechaInicio(filtroTiempo);

    // Ejecutamos consultas paralelas
    final resPedidos = await _db.obtenerPedidosParaEstadisticas(fechaInicio);
    final resMovimientos = await _db.obtenerHistorialMovimientos(fechaInicio);
    final resVariantesMarcas = await _db.obtenerVariantesConMarcas();

    // -------------------------------------------------------------
    // A) PROCESAR PEDIDOS Y TOP PRODUCTOS / FAMILIAS
    // -------------------------------------------------------------
    double totalVentasAcumuladas = 0;
    Map<int, Map<String, dynamic>> conteoProductos = {};
    Map<String, double> conteoFamilias = {};

    for (var pedido in resPedidos) {
      final detalles = pedido['pedido_detalles'] as List<dynamic>? ?? [];
      for (var det in detalles) {
        final int cantidad = det['cantidad'] ?? 0;
        final double precio = (det['precio_unitario'] ?? 0).toDouble();
        final double subtotal = cantidad * precio;

        totalVentasAcumuladas += subtotal;

        final variante = det['variantes'];
        if (variante != null) {
          final producto = variante['productos'];
          if (producto != null) {
            final int prodId = producto['id'];
            final String prodNombre = producto['nombre'] ?? 'Sin Nombre';
            final String? img = producto['imagen_principal'];

            if (!conteoProductos.containsKey(prodId)) {
              conteoProductos[prodId] = {
                'id': prodId,
                'nombre': prodNombre,
                'imagen': img,
                'unidades': 0,
                'recaudado': 0.0,
              };
            }
            conteoProductos[prodId]!['unidades'] += cantidad;
            conteoProductos[prodId]!['recaudado'] += subtotal;

            final familiaObj = producto['familias_olfativas'];
            final String familiaNombre = familiaObj != null
                ? familiaObj['nombre'] ?? 'Sin Familia'
                : 'Sin Familia';

            conteoFamilias[familiaNombre] =
                (conteoFamilias[familiaNombre] ?? 0) + cantidad;
          }
        }
      }
    }

    List<ItemRankingModel> listaProductos = conteoProductos.values.map((map) {
      return ItemRankingModel(
        id: map['id'],
        nombre: map['nombre'],
        imagen: map['imagen'],
        unidadesVendidas: map['unidades'],
        totalRecaudado: map['recaudado'],
      );
    }).toList();

    listaProductos.sort(
      (a, b) => b.unidadesVendidas.compareTo(a.unidadesVendidas),
    );

    // -------------------------------------------------------------
    // B) PROCESAR FLUJO DE ENTRADAS VS SALIDAS
    // -------------------------------------------------------------
    Map<String, Map<String, int>> agrupaFlujo = {};

    for (var mov in resMovimientos) {
      final DateTime fecha = DateTime.parse(mov['fecha']);
      final String label = "${fecha.day}/${fecha.month}";
      final String tipo = mov['tipo_movimiento'] ?? '';
      final int cantidad = mov['cantidad'] ?? 0;

      if (!agrupaFlujo.containsKey(label)) {
        agrupaFlujo[label] = {'Entrada': 0, 'Salida': 0};
      }

      if (tipo == 'Entrada') {
        agrupaFlujo[label]!['Entrada'] =
            (agrupaFlujo[label]!['Entrada'] ?? 0) + cantidad;
      } else if (tipo == 'Salida') {
        agrupaFlujo[label]!['Salida'] =
            (agrupaFlujo[label]!['Salida'] ?? 0) + cantidad;
      }
    }

    List<ItemFlujoMovimientoModel> flujo = agrupaFlujo.entries.map((entry) {
      return ItemFlujoMovimientoModel(
        fechaLabel: entry.key,
        entradas: entry.value['Entrada'] ?? 0,
        salidas: entry.value['Salida'] ?? 0,
      );
    }).toList();

    // -------------------------------------------------------------
    // C) PROCESAR TOP MARCAS POR VALOR MONETARIO (Stock * Costo)
    // -------------------------------------------------------------
    Map<String, double> valorPorMarca = {};

    for (var v in resVariantesMarcas) {
      final int stock = v['stock'] ?? 0;
      final double costo = (v['costo_compra'] ?? 0).toDouble();
      final double totalValor = stock * costo;

      final prod = v['productos'];
      String marcaNombre = 'Sin Marca';
      if (prod != null && prod['marcas'] != null) {
        marcaNombre = prod['marcas']['nombre'] ?? 'Sin Marca';
      }

      valorPorMarca[marcaNombre] =
          (valorPorMarca[marcaNombre] ?? 0) + totalValor;
    }

    List<ItemMarcaValorModel> topMarcas = valorPorMarca.entries.map((entry) {
      return ItemMarcaValorModel(marca: entry.key, valorTotal: entry.value);
    }).toList();

    topMarcas.sort((a, b) => b.valorTotal.compareTo(a.valorTotal));

    return ReporteVentasModel(
      totalVentas: totalVentasAcumuladas,
      top10MasVendidos: listaProductos.take(10).toList(),
      familiasMasVendidas: conteoFamilias.entries
          .map((e) => ItemFamiliaModel(familia: e.key, cantidad: e.value))
          .toList(),
      fraganciasMenosVendidas: listaProductos.reversed.take(5).toList(),
      flujoMovimientos: flujo.take(7).toList(), // Mostramos últimos 7 rangos
      topMarcasValor: topMarcas.take(5).toList(), // Top 5 marcas
    );
  }

  DateTime? _calcularFechaInicio(String filtro) {
    final ahora = DateTime.now();
    switch (filtro) {
      case 'Semanal':
        return ahora.subtract(const Duration(days: 7));
      case 'Mensual':
        return DateTime(ahora.year, ahora.month - 1, ahora.day);
      case 'Anual':
        return DateTime(ahora.year - 1, ahora.month, ahora.day);
      case 'Todo':
      default:
        return null;
    }
  }
}
