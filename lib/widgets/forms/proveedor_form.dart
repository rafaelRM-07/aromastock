import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/proveedor_model.dart';
import '../../data/providers/proveedor_provider.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class ProveedorForm extends StatefulWidget {
  final ProveedorModel? proveedor;

  const ProveedorForm({super.key, this.proveedor});

  @override
  State<ProveedorForm> createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<ProveedorForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _contactoController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.proveedor?.nombreEmpresa ?? '',
    );
    _contactoController = TextEditingController(
      text: widget.proveedor?.contactoNombre ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.proveedor?.telefono ?? '',
    );
    _correoController = TextEditingController(
      text: widget.proveedor?.correo ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contactoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final provider = context.read<ProveedorProvider>();

      final proveedorData = ProveedorModel(
        id: widget.proveedor?.id,
        nombreEmpresa: _nombreController.text.trim(),
        contactoNombre: _contactoController.text.trim().isNotEmpty
            ? _contactoController.text.trim()
            : null,
        telefono: _telefonoController.text.trim().isNotEmpty
            ? _telefonoController.text.trim()
            : null,
        correo: _correoController.text.trim().isNotEmpty
            ? _correoController.text.trim()
            : null,
      );

      await provider.guardar(proveedorData);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el proveedor: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- CAMPO NOMBRE EMPRESA (Máx 30 caracteres, solo letras) ---
              CustomTextField(
                controller: _nombreController,
                label: 'Nombre Empresa',
                icon: Icons.business,
                maxLength: 30,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                  ),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre de la empresa es obligatorio';
                  }
                  if (v.trim().length > 30) {
                    return 'Máximo 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- CAMPO CONTACTO (Máx 30 caracteres, solo letras) ---
              CustomTextField(
                controller: _contactoController,
                label: 'Contacto',
                icon: Icons.person,
                maxLength: 30,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                  ),
                ],
                validator: (v) {
                  if (v != null &&
                      v.trim().isNotEmpty &&
                      v.trim().length > 30) {
                    return 'Máximo 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- CAMPO TELÉFONO CON BANDERA, +52 Y 10 DÍGITOS ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Text('🇲🇽', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 6),
                        Text(
                          '+52',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            v.trim().length < 10) {
                          return 'Debe tener exactamente 10 dígitos';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- CAMPO CORREO (Validación estricta de estructura email) ---
              CustomTextField(
                controller: _correoController,
                label: 'Correo Electrónico',
                icon: Icons.email,
                maxLength: 100,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
                ],
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final regex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!regex.hasMatch(v.trim())) {
                      return 'Ingrese un correo electrónico válido (ej. correo@domain.com)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- BOTÓN GUARDAR ---
              CustomButton(
                text: esEdicion ? 'Actualizar Proveedor' : 'Guardar Proveedor',
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
