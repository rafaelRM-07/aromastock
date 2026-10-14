import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/providers/proveedor_provider.dart';
import '../../data/models/proveedor_model.dart';
import '../../widgets/forms/proveedor_form.dart';
import '../../widgets/forms/proveedor_producto_form.dart';
import '../../widgets/dialogs/base_dialog.dart';

class ProveedoresView extends StatefulWidget {
  const ProveedoresView({super.key});

  @override
  State<ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<ProveedoresView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProveedorProvider>(context, listen: false);
      provider.cargar();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProveedorProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A0E0E),
        title: const Text(
          "Proveedores",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: (provider.cargando && provider.lista.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A0E0E)),
            )
          : provider.lista.isEmpty
          ? const Center(
              child: Text(
                "No hay proveedores registrados",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.lista.length,
              itemBuilder: (context, index) {
                final p = provider.lista[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF4A0E0E),
                          ),
                        ),
                        title: Text(
                          p.nombreEmpresa,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            p.contactoNombre ?? 'Sin contacto',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        children: [
                          const Divider(height: 1, color: Color(0xFFF1F3F5)),
                          const SizedBox(height: 8),
                          _ProductosVinculadosList(proveedorId: p.id!),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _ActionIconButton(
                                icon: Icons.link,
                                color: Colors.green,
                                onPressed: () => _showVinculacion(p),
                              ),
                              const SizedBox(width: 8),
                              _ActionIconButton(
                                icon: Icons.edit_rounded,
                                color: Colors.blue,
                                onPressed: () => _showForm(p),
                              ),
                              const SizedBox(width: 8),
                              _ActionIconButton(
                                icon: Icons.delete_rounded,
                                color: Colors.redAccent,
                                onPressed: () => _confirmarEliminar(p),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A0E0E),
        elevation: 4,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    try {
      Provider.of<ProveedorProvider>(context, listen: false).stopRealtime();
    } catch (_) {}
    super.dispose();
  }

  void _showForm([ProveedorModel? p]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ProveedorForm(proveedor: p),
      ),
    );
  }

  void _showVinculacion(ProveedorModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ProveedorProductoForm(
          proveedorIdPreseleccionado: p.id,
          nombreProveedorPreseleccionado: p.nombreEmpresa,
        ),
      ),
    );
  }

  void _confirmarEliminar(ProveedorModel p) {
    showDialog(
      context: context,
      builder: (_) => BaseDialog(
        title: "Eliminar Proveedor",
        message: "¿Seguro que deseas eliminar a ${p.nombreEmpresa}?",
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProveedorProvider>(
                context,
                listen: false,
              ).borrar(p.id!);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Botón de acción minimalista y limpio
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// --- WIDGET AUXILIAR OPTIMIZADO (Diseño Limpio) ---
class _ProductosVinculadosList extends StatefulWidget {
  final int proveedorId;
  const _ProductosVinculadosList({required this.proveedorId});

  @override
  State<_ProductosVinculadosList> createState() =>
      _ProductosVinculadosListState();
}

class _ProductosVinculadosListState extends State<_ProductosVinculadosList> {
  late final Future<List<dynamic>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _futureProductos = Supabase.instance.client
        .from('proveedor_productos')
        .select('costo_pactado, variantes(sku)')
        .eq('proveedor_id', widget.proveedorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureProductos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4A0E0E),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Error al cargar productos",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "Sin productos vinculados",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          );
        }

        return Column(
          children: data.map<Widget>((item) {
            final v = item['variantes'];
            final costoPactado = item['costo_pactado'];
            if (v == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "SKU: ${v['sku'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    "\$$costoPactado",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A0E0E),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
