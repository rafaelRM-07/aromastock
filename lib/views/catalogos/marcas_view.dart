import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/marcas_provider.dart';
import '../../data/models/marcas_model.dart';
import '../../widgets/forms/marcas_form.dart';
import '../../widgets/dialogs/base_dialog.dart';

class MarcasView extends StatefulWidget {
  const MarcasView({super.key});

  @override
  State<MarcasView> createState() => _MarcasViewState();
}

class _MarcasViewState extends State<MarcasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MarcaProvider>(context, listen: false);
      provider.cargarMarcas();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarcaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Marcas", style: TextStyle(color: Color(0xFF4A0E0E))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A0E0E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: (provider.cargando && provider.lista.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A0E0E)),
            )
          : provider.lista.isEmpty
          ? const Center(child: Text("No hay marcas registradas"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.lista.length,
              itemBuilder: (context, index) {
                final item = provider.lista[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(
                        Icons.branding_watermark,
                        color: Color(0xFF4A0E0E),
                      ),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(model: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminar(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A0E0E),
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    try {
      Provider.of<MarcaProvider>(context, listen: false).stopRealtime();
    } catch (_) {}
    super.dispose();
  }

  void _showForm({MarcaModel? model}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MarcaForm(model: model),
    );
  }

  void _confirmarEliminar(MarcaModel model) {
    showDialog(
      context: context,
      builder: (_) => BaseDialog(
        title: "Eliminar Marca",
        message: "¿Seguro que deseas eliminar la marca '${model.nombre}'?",
        titleColor: Colors.redAccent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MarcaProvider>(
                context,
                listen: false,
              ).borrar(model.id!);
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
}
