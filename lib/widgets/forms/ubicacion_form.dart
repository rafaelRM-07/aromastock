import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/ubicacion_model.dart';
import '../../data/providers/ubicacion_provider.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class UbicacionForm extends StatefulWidget {
  final UbicacionModel? ubicacion;

  const UbicacionForm({super.key, this.ubicacion});

  @override
  State<UbicacionForm> createState() => _UbicacionFormState();
}

class _UbicacionFormState extends State<UbicacionForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _zonaController;
  late TextEditingController _estanteController;

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _zonaController = TextEditingController(text: widget.ubicacion?.zona ?? '');
    _estanteController = TextEditingController(
      text: widget.ubicacion?.estante ?? '',
    );
  }

  @override
  void dispose() {
    _zonaController.dispose();
    _estanteController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final provider = context.read<UbicacionProvider>();
    final nuevaUbicacion = UbicacionModel(
      id: widget.ubicacion?.id,
      zona: _zonaController.text.trim().toUpperCase(),
      estante: _estanteController.text.trim(),
    );

    await provider.guardar(nuevaUbicacion);

    if (mounted) {
      setState(() => _cargando = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.ubicacion != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Ubicación' : 'Nueva Ubicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion
                    ? 'Actualizar Datos de Ubicación'
                    : 'Registrar Nueva Ubicación',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- ZONA (Obligatorio: una letra y un número, ej. A1) ---
              CustomTextField(
                controller: _zonaController,
                label: 'Zona (ej. A1)',
                icon: Icons.map,
                maxLength: 2,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  // Permite letras en la posición 1 y números en la 2
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    if (text.isEmpty) return newValue;
                    if (text.length == 1) {
                      // El primer caracter debe ser letra
                      return RegExp(r'^[a-zA-Z]$').hasMatch(text)
                          ? newValue
                          : oldValue;
                    }
                    if (text.length == 2) {
                      // El segundo caracter debe ser número
                      return RegExp(r'^[a-zA-Z][0-9]$').hasMatch(text)
                          ? newValue
                          : oldValue;
                    }
                    return oldValue;
                  }),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'La zona es obligatoria';
                  }
                  final regex = RegExp(r'^[A-Z][0-9]$');
                  if (!regex.hasMatch(v.trim().toUpperCase())) {
                    return 'Formato inválido. Debe ser una letra y un número (ej. A1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- NÚMERO DE ESTANTE (Solo números, máximo 3 dígitos) ---
              CustomTextField(
                controller: _estanteController,
                label: 'Número de Estante',
                icon: Icons.shelves,
                maxLength: 3,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El número de estante es obligatorio';
                  }
                  if (v.trim().length > 3) {
                    return 'Máximo 3 dígitos permitidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: esEdicion ? 'Actualizar Ubicación' : 'Guardar Ubicación',
                isLoading: _cargando,
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
