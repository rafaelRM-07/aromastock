import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/familia_olfativa_provider.dart';
import '../../data/models/familia_olfativa_model.dart';
import '../../widgets/forms/familia_olfativa_form.dart';
//
import '../../widgets/dialogs/base_dialog.dart';

class FamiliasOlfativasView extends StatefulWidget {
  const FamiliasOlfativasView({super.key});

  @override
  State<FamiliasOlfativasView> createState() => _FamiliasOlfativasViewState();
}

class _FamiliasOlfativasViewState extends State<FamiliasOlfativasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FamiliaOlfativaProvider>(context, listen: false);
      provider.cargar();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FamiliaOlfativaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Familias Olfativas",
          style: TextStyle(color: Color(0xFF4A0E0E)),
        ),
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
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.lista.length,
              itemBuilder: (context, index) {
                final item = provider.lista[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(Icons.grass, color: Color(0xFF4A0E0E)),
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
      Provider.of<FamiliaOlfativaProvider>(context, listen: false).stopRealtime();
    } catch (_) {}
    super.dispose();
  }

  void _showForm({FamiliaOlfativaModel? model}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FamiliaOlfativaForm(model: model),
    );
  }

  void _confirmarEliminar(FamiliaOlfativaModel model) {
    showDialog(
      context: context,
      builder: (_) => BaseDialog(
        title: "Eliminar Familia",
        message: "¿Seguro que deseas eliminar '${model.nombre}'?",
        titleColor: Colors.redAccent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FamiliaOlfativaProvider>(
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
