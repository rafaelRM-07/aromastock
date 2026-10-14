class ReporteVentasModel {
  final double totalVentas;
  final List<ItemRankingModel> top10MasVendidos;
  final List<ItemFamiliaModel> familiasMasVendidas;
  final List<ItemRankingModel> fraganciasMenosVendidas;
  // NUEVA: Flujo de Movimientos
  final List<ItemFlujoMovimientoModel> flujoMovimientos;
  // NUEVA: Top Marcas
  final List<ItemMarcaValorModel> topMarcasValor;

  ReporteVentasModel({
    required this.totalVentas,
    required this.top10MasVendidos,
    required this.familiasMasVendidas,
    required this.fraganciasMenosVendidas,
    required this.flujoMovimientos,
    required this.topMarcasValor,
  });
}

class ItemRankingModel {
  final int id;
  final String nombre;
  final String? imagen;
  final int unidadesVendidas;
  final double totalRecaudado;

  ItemRankingModel({
    required this.id,
    required this.nombre,
    this.imagen,
    required this.unidadesVendidas,
    required this.totalRecaudado,
  });
}

class ItemFamiliaModel {
  final String familia;
  final double cantidad;

  ItemFamiliaModel({required this.familia, required this.cantidad});
}

// MODELO 1: FLUJO DE ENTRADAS VS SALIDAS
class ItemFlujoMovimientoModel {
  final String fechaLabel; // Ej: "10/08" o "Lun"
  final int entradas;
  final int salidas;

  ItemFlujoMovimientoModel({
    required this.fechaLabel,
    required this.entradas,
    required this.salidas,
  });
}

// MODELO 2: TOP MARCAS POR VALOR EN INVENTARIO
class ItemMarcaValorModel {
  final String marca;
  final double valorTotal;

  ItemMarcaValorModel({required this.marca, required this.valorTotal});
}
