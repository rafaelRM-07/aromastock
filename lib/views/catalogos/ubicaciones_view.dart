import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/ubicacion_provider.dart';
import '../../data/models/ubicacion_model.dart';
import '../../widgets/forms/ubicacion_form.dart'; // Asegúrate de tener este form
import '../../widgets/dialogs/base_dialog.dart';

class UbicacionesView extends StatefulWidget {
  const UbicacionesView({super.key});

  @override
  State<UbicacionesView> createState() => _UbicacionesViewState();
}

class _UbicacionesViewState extends State<UbicacionesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UbicacionProvider>(context, listen: false);
      provider.cargar();
      provider.initRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UbicacionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Ubicaciones",
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
          : provider.lista.isEmpty
          ? const Center(child: Text("No hay ubicaciones registradas"))
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
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF3E5F5),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: const Color(0xFF4A0E0E),
                      ),
                    ),
                    title: Text(
                      "${item.zona} - Estante ${item.estante}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Estado: ${item.estadoLogistico}"),
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
      Provider.of<UbicacionProvider>(context, listen: false).stopRealtime();
    } catch (_) {}
    super.dispose();
  }

  void _showForm({UbicacionModel? model}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UbicacionForm(
        ubicacion: model,
      ), // Asegúrate que tu form acepte 'ubicacion'
    );
  }

  void _confirmarEliminar(UbicacionModel model) {
    showDialog(
      context: context,
      builder: (_) => BaseDialog(
        title: "Eliminar Ubicación",
        message:
            "¿Seguro que deseas eliminar la ubicación '${model.zona}-${model.estante}'?",
        titleColor: Colors.redAccent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UbicacionProvider>(
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
