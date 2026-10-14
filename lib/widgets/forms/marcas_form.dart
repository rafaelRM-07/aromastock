import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/providers/marcas_provider.dart';
import '../../data/models/marcas_model.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class MarcaForm extends StatefulWidget {
  final MarcaModel? model;
  const MarcaForm({super.key, this.model});

  @override
  State<MarcaForm> createState() => _MarcaFormState();
}

class _MarcaFormState extends State<MarcaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.model?.nombre ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final marcaProvider = context.read<MarcaProvider>();
    await marcaProvider.guardar(
      MarcaModel(id: widget.model?.id, nombre: _ctrl.text.trim()),
    );

    if (mounted) {
      setState(() => _cargando = false);
      Navigator.pop(context);
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
              widget.model != null ? 'Editar Marca' : 'Nueva Marca',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _ctrl,
              label: 'Nombre de la Marca (Ej: Dior, Chanel)',
              icon: Icons.branding_watermark,
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
                  return 'El nombre de la marca es obligatorio';
                }
                if (val.trim().length > 30) {
                  return 'Máximo 30 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: widget.model != null ? 'Actualizar' : 'Guardar',
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
