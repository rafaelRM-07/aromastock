import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/providers/categoria_provider.dart';
import '../../data/models/categoria_model.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class CategoriaForm extends StatefulWidget {
  final CategoriaModel? categoria; // Si es null, es creación

  const CategoriaForm({super.key, this.categoria});

  @override
  State<CategoriaForm> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Si recibimos categoría, precargamos los datos
    _nombreCtrl = TextEditingController(text: widget.categoria?.nombre ?? '');
    _descCtrl = TextEditingController(
      text: widget.categoria?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final provider = context.read<CategoriaProvider>();

    // Creamos el modelo con los datos del formulario
    final categoria = CategoriaModel(
      id: widget.categoria?.id, // Mantiene el ID si es edición
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
    );

    try {
      if (widget.categoria == null) {
        await provider.crear(categoria);
      } else {
        await provider.editar(categoria);
      }

      if (mounted) {
        setState(() => _cargando = false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoria == null ? 'Nueva Categoría' : 'Editar Categoría',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo Nombre de Categoría (Máx 30 caracteres, SOLO letras y espacios)
            CustomTextField(
              controller: _nombreCtrl,
              label: 'Nombre de la categoría',
              icon: Icons.category_rounded,
              keyboardType: TextInputType.name,
              maxLength: 30,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                ),
              ],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (val.trim().length > 30) {
                  return 'Máximo 30 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo Descripción (Máx 120 caracteres, permite letras y números)
            CustomTextField(
              controller: _descCtrl,
              label: 'Descripción (opcional)',
              icon: Icons.description_rounded,
              keyboardType: TextInputType.text,
              maxLength: 120,
              inputFormatters: [
                LengthLimitingTextInputFormatter(120),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]'),
                ),
              ],
              validator: (val) {
                if (val != null && val.trim().length > 120) {
                  return 'Máximo 120 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: widget.categoria == null ? 'Guardar' : 'Actualizar',
              isLoading: _cargando,
              onPressed: _guardar,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
