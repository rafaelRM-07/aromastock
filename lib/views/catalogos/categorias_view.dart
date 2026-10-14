import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/categoria_model.dart';
import '../../data/providers/categoria_provider.dart';
import '../../widgets/forms/categoria_form.dart';
//
import '../../widgets/dialogs/base_dialog.dart';

class CategoriasView extends StatefulWidget {
  const CategoriasView({super.key});

  @override
  State<CategoriasView> createState() => _CategoriasViewState();
}

class _CategoriasViewState extends State<CategoriasView> {
  @override
  void initState() {
    super.initState();
    // Cargamos los datos al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<CategoriaProvider>(context, listen: false);
      prov.cargarCategorias();
      prov.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoriaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Categorías"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A1B29),
        elevation: 0,
      ),
      body: (provider.cargando && provider.lista.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B29)),
            )
          : provider.lista.isEmpty
          ? const Center(child: Text("No hay categorías registradas"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.lista.length,
              itemBuilder: (context, index) {
                final cat = provider.lista[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(Icons.category, color: Color(0xFF6A1B29)),
                    ),
                    title: Text(
                      cat.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(cat.descripcion ?? "Sin descripción"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(categoria: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminar(cat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B29),
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showForm({CategoriaModel? categoria}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoriaForm(categoria: categoria),
    );
  }

  void _confirmarEliminar(CategoriaModel categoria) {
    showDialog(
      context: context,
      builder: (_) => BaseDialog(
        title: "Eliminar Categoría",
        message:
            "¿Estás seguro de eliminar '${categoria.nombre}'? Esta acción no se puede deshacer.",
        titleColor: Colors.redAccent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoriaProvider>(
                context,
                listen: false,
              ).borrar(categoria.id!);
              Navigator.pop(context);
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      Provider.of<CategoriaProvider>(context, listen: false).stopRealtime();
    } catch (_) {}
    super.dispose();
  }
}
