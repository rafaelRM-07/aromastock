import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/providers/familia_olfativa_provider.dart';
import '../../data/models/familia_olfativa_model.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class FamiliaOlfativaForm extends StatefulWidget {
  final FamiliaOlfativaModel? model;
  const FamiliaOlfativaForm({super.key, this.model});

  @override
  State<FamiliaOlfativaForm> createState() => _FamiliaOlfativaFormState();
}

class _FamiliaOlfativaFormState extends State<FamiliaOlfativaForm> {
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

    final provider = context.read<FamiliaOlfativaProvider>();
    await provider.guardar(
      FamiliaOlfativaModel(id: widget.model?.id, nombre: _ctrl.text.trim()),
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
              widget.model != null
                  ? 'Editar Familia Olfativa'
                  : 'Nueva Familia Olfativa',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _ctrl,
              label: 'Familia Olfativa (Ej: Aromática, Especiada)',
              icon: Icons.grass,
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
                  return 'La familia olfativa es obligatoria';
                }
                if (val.trim().length > 20) {
                  return 'Máximo 20 caracteres';
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
