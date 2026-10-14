import 'package:flutter/material.dart';

class ModalProductoNoEncontrado extends StatelessWidget {
  final String codigoEscaneado;
  final VoidCallback onRegistrarNuevo;
  final VoidCallback onEntradaSalida;

  const ModalProductoNoEncontrado({
    super.key,
    required this.codigoEscaneado,
    required this.onRegistrarNuevo,
    required this.onEntradaSalida,
  });

  static void mostrar(
    BuildContext context, {
    required String codigo,
    required VoidCallback onRegistrarNuevo,
    required VoidCallback onEntradaSalida,
    VoidCallback? onCancelar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModalProductoNoEncontrado(
        codigoEscaneado: codigo,
        onRegistrarNuevo: onRegistrarNuevo,
        onEntradaSalida: onEntradaSalida,
      ),
    ).then((_) {
      if (onCancelar != null) onCancelar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual de arrastre arriba
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Ícono de estado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 12),

          // Título y Código
          const Text(
            'Producto no registrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              children: [
                const TextSpan(text: 'El código / SKU '),
                TextSpan(
                  text: '"$codigoEscaneado"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(text: ' no se encuentra en el sistema.'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // OPCIÓN 1: Registrar Nuevo Producto
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            tileColor: Colors.grey.shade50,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF4A1519), // Vino oscuro
              child: Icon(Icons.add_rounded, color: Colors.white),
            ),
            title: const Text(
              'Registrar Nuevo Producto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Crear un producto asignándole este SKU'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(context);
              onRegistrarNuevo();
            },
          ),

          const SizedBox(height: 10),

          // OPCIÓN 2: Ajuste Rápido de Entrada / Salida
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            tileColor: Colors.grey.shade50,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.swap_vert_rounded, color: Colors.blue.shade900),
            ),
            title: const Text(
              'Entrada / Salida Rápida',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Registrar movimiento sin catálogo previo'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(context);
              onEntradaSalida();
            },
          ),

          const SizedBox(height: 16),

          // OPCIÓN 3: Cancelar
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cancelar / Volver a escanear',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
