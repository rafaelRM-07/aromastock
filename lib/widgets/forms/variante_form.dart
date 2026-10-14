import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/models/variante_model.dart';
import '../../../data/providers/variantes_provider.dart';
import '../../views/scanner/scan_view.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import '../dialogs/base_dialog.dart';

class VarianteForm extends StatefulWidget {
  final int productoId;
  final VarianteModel? variante;

  const VarianteForm({super.key, required this.productoId, this.variante});

  @override
  State<VarianteForm> createState() => _VarianteFormState();
}

class _VarianteFormState extends State<VarianteForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _skuController;
  late TextEditingController _mlController;
  late TextEditingController _stockController;
  late TextEditingController _costoController;
  late TextEditingController _precioController;

  bool _cargando = false;

  // 0 para Mililitros (ml), 1 para Litros (L)
  int _unidadMedidaIndex = 0;

  @override
  void initState() {
    super.initState();
    _inicializarCampos();
  }

  void _inicializarCampos() {
    _skuController = TextEditingController(text: widget.variante?.sku ?? '');

    final mlInicial = widget.variante?.mililitros;
    if (mlInicial != null && mlInicial >= 1000 && mlInicial % 1000 == 0) {
      _mlController = TextEditingController(
        text: (mlInicial ~/ 1000).toString(),
      );
      _unidadMedidaIndex = 1; // Litros
    } else {
      _mlController = TextEditingController(text: mlInicial?.toString() ?? '');
      _unidadMedidaIndex = 0; // Mililitros
    }

    _stockController = TextEditingController(
      text: widget.variante?.stock.toString() ?? '0',
    );

    final costoInicial = widget.variante?.costoCompra;
    _costoController = TextEditingController(
      text: costoInicial != null
          ? double.parse(costoInicial.toString()).toStringAsFixed(2)
          : '',
    );

    final precioInicial = widget.variante?.precioVenta;
    _precioController = TextEditingController(
      text: precioInicial != null
          ? double.parse(precioInicial.toString()).toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _skuController.dispose();
    _mlController.dispose();
    _stockController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // Método que se ejecuta al deslizar hacia abajo (Pull-to-Refresh)
  Future<void> _recargarDatos() async {
    setState(() {
      _cargando = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    _inicializarCampos();

    if (!mounted) return;
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _abrirEscanerSKU() async {
    if (widget.variante != null) return;
    final String? codigoEscaneado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScanView()),
    );

    if (codigoEscaneado != null && codigoEscaneado.isNotEmpty) {
      if (!mounted) return;
      final provider = context.read<VarianteProvider>();
      bool skuExiste = provider.variantes.any(
        (v) => v.sku.toLowerCase() == codigoEscaneado.toLowerCase(),
      );

      if (!mounted) return;

      if (skuExiste) {
        showDialog(
          context: context,
          builder: (context) => BaseDialog(
            title: 'SKU Duplicado',
            message:
                'Este SKU ya está registrado en otro producto u otra variante.',
            titleColor: const Color(0xFF6A1B29),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Color(0xFF6A1B29),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _skuController.text = codigoEscaneado;
        });
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VarianteProvider>();
    final skuActual = _skuController.text.trim();

    bool skuExiste = provider.variantes.any(
      (v) =>
          v.sku.toLowerCase() == skuActual.toLowerCase() &&
          (widget.variante == null || v.id != widget.variante?.id),
    );

    if (!mounted) return;

    if (skuExiste) {
      showDialog(
        context: context,
        builder: (context) => BaseDialog(
          title: 'SKU Duplicado',
          message:
              'Este SKU ya está registrado en otro producto u otra variante.',
          titleColor: const Color(0xFF6A1B29),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF6A1B29),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    int? valorMl = int.tryParse(_mlController.text.trim());
    if (valorMl != null && _unidadMedidaIndex == 1) {
      valorMl = valorMl * 1000;
    }

    final variante = VarianteModel(
      id: widget.variante?.id,
      productoId: widget.productoId,
      sku: skuActual,
      mililitros: valorMl,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      costoCompra: double.tryParse(_costoController.text.trim()) ?? 0.0,
      precioVenta: double.tryParse(_precioController.text.trim()) ?? 0.0,
      activo: widget.variante?.activo ?? true,
    );

    bool exito = widget.variante == null
        ? await provider.agregar(variante)
        : await provider.editar(variante);

    if (!mounted) return;
    setState(() => _cargando = false);

    if (exito) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => BaseDialog(
          title: 'Error',
          message: 'Error al guardar la variante.',
          titleColor: const Color(0xFF6A1B29),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Color(0xFF6A1B29),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.variante != null;

    return RefreshIndicator(
      color: const Color(0xFF6A1B29),
      onRefresh: _recargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion ? 'Editar Variante' : 'Nueva Variante',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: esEdicion ? null : _abrirEscanerSKU,
                child: AbsorbPointer(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _skuController,
                          label: 'Código SKU / Barras',
                          icon: Icons.qr_code,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\-_]'),
                            ),
                          ],
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Debes escanear o ingresar un SKU'
                              : null,
                        ),
                      ),
                      if (!esEdicion) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B29),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: _abrirEscanerSKU,
                          icon: const Icon(Icons.qr_code_scanner),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- CAMPO MILILITROS / LITROS CON SELECTOR ---
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _mlController,
                      label: _unidadMedidaIndex == 0
                          ? 'Capacidad (ml)'
                          : 'Capacidad (Litros)',
                      icon: Icons.local_drink,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final val = int.tryParse(v.trim());
                          if (val == null || val <= 0) {
                            return 'Ingrese un valor válido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToggleButtons(
                    isSelected: [
                      _unidadMedidaIndex == 0,
                      _unidadMedidaIndex == 1,
                    ],
                    onPressed: (index) {
                      setState(() {
                        _unidadMedidaIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFF6A1B29),
                    color: Colors.black87,
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 45,
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'ml',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'L',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- STOCK INICIAL ---
              CustomTextField(
                controller: _stockController,
                label: 'Stock Inicial',
                icon: Icons.inventory_2,
                maxLength: 5,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingrese stock';
                  }
                  final val = int.tryParse(v.trim());
                  if (val == null || val < 0) {
                    return 'Ingrese un stock válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- COSTO DE COMPRA ---
              TextFormField(
                controller: _costoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 10,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: _inputDecoration(
                  'Costo de Compra (\$)',
                  Icons.attach_money,
                ).copyWith(counterText: ''),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El costo de compra es obligatorio';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
                onEditingComplete: () {
                  if (_costoController.text.isNotEmpty) {
                    final val = double.tryParse(_costoController.text);
                    if (val != null) {
                      _costoController.text = val.toStringAsFixed(2);
                    }
                  }
                },
              ),
              const SizedBox(height: 12),

              // --- PRECIO DE VENTA ---
              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 10,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: _inputDecoration(
                  'Precio de Venta (\$)',
                  Icons.sell,
                ).copyWith(counterText: ''),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El precio de venta es obligatorio';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
                onEditingComplete: () {
                  if (_precioController.text.isNotEmpty) {
                    final val = double.tryParse(_precioController.text);
                    if (val != null) {
                      _precioController.text = val.toStringAsFixed(2);
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: esEdicion ? 'Actualizar Variante' : 'Guardar Variante',
                isLoading: _cargando,
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF6A1B29)),
      filled: true,
      fillColor: Colors.grey.shade50,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6A1B29), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
