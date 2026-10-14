import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/providers/proveedor_provider.dart';
import '../../data/providers/variantes_provider.dart';
import '../common/custom_button.dart';

class ProveedorProductoForm extends StatefulWidget {
  final Map<String, dynamic>? proveedorProducto;
  final int? proveedorIdPreseleccionado;
  final String? nombreProveedorPreseleccionado;

  const ProveedorProductoForm({
    super.key,
    this.proveedorProducto,
    this.proveedorIdPreseleccionado,
    this.nombreProveedorPreseleccionado,
  });

  @override
  State<ProveedorProductoForm> createState() => _ProveedorProductoFormState();
}

class _ProveedorProductoFormState extends State<ProveedorProductoForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedProveedor;
  int? _selectedVariante;
  late TextEditingController _costoController;

  String _nombreProveedorFijo = '';
  bool _cargando = false;
  bool _cargandoProveedorRemoto = false;

  @override
  void initState() {
    super.initState();

    _selectedProveedor =
        widget.proveedorProducto?['proveedor_id'] ??
        widget.proveedorIdPreseleccionado;

    _selectedVariante = widget.proveedorProducto?['variante_id'];

    final costoInicial = widget.proveedorProducto?['costo_pactado'];
    _costoController = TextEditingController(
      text: costoInicial != null
          ? double.parse(costoInicial.toString()).toStringAsFixed(2)
          : '',
    );

    if (widget.nombreProveedorPreseleccionado != null) {
      _nombreProveedorFijo = widget.nombreProveedorPreseleccionado!;
    } else if (widget.proveedorProducto != null &&
        widget.proveedorProducto!['proveedores'] != null) {
      _nombreProveedorFijo =
          widget.proveedorProducto!['proveedores']['nombre_empresa'] ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VarianteProvider>().cargarTodas();
      final provProvider = context.read<ProveedorProvider>();
      if (provProvider.lista.isEmpty) {
        provProvider.cargar();
      }

      if (_nombreProveedorFijo.isEmpty && _selectedProveedor != null) {
        _obtenerNombreProveedorDirecto(_selectedProveedor!);
      }
    });
  }

  Future<void> _obtenerNombreProveedorDirecto(int proveedorId) async {
    setState(() => _cargandoProveedorRemoto = true);
    try {
      final response = await Supabase.instance.client
          .from('proveedores')
          .select('nombre_empresa')
          .eq('id', proveedorId)
          .single();

      if (mounted) {
        setState(() {
          _nombreProveedorFijo =
              response['nombre_empresa'] ?? 'Proveedor #$proveedorId';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _nombreProveedorFijo = 'Proveedor #$proveedorId';
        });
      }
    } finally {
      if (mounted) setState(() => _cargandoProveedorRemoto = false);
    }
  }

  @override
  void dispose() {
    _costoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProveedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: No se ha pasado el ID del proveedor correctamente.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final nav = Navigator.of(context);
      final costoValor = double.parse(_costoController.text.trim());

      if (widget.proveedorProducto?['id'] != null) {
        await Supabase.instance.client
            .from('proveedor_productos')
            .update({
              'proveedor_id': _selectedProveedor,
              'variante_id': _selectedVariante,
              'costo_pactado': costoValor,
            })
            .eq('id', widget.proveedorProducto!['id']);
      } else {
        await Supabase.instance.client.from('proveedor_productos').insert({
          'proveedor_id': _selectedProveedor,
          'variante_id': _selectedVariante,
          'costo_pactado': costoValor,
        });
      }

      if (!mounted) return;
      nav.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la vinculación: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final varProvider = context.watch<VarianteProvider>();
    final provProvider = context.watch<ProveedorProvider>();
    final esEdicion = widget.proveedorProducto != null;

    if (_nombreProveedorFijo.isEmpty && _selectedProveedor != null) {
      try {
        final prov = provProvider.lista.firstWhere(
          (p) => p.id == _selectedProveedor,
        );
        _nombreProveedorFijo = prov.nombreEmpresa;
      } catch (_) {}
    }

    final varianteValor =
        varProvider.variantes.any((v) => v.id == _selectedVariante)
        ? _selectedVariante
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior pequeña indicadora de modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título y subtítulo limpios
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFE74C3C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Color(0xFF6A1B29),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esEdicion ? 'Editar Costo' : 'Vincular Producto',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          esEdicion
                              ? 'Modifica los detalles del costo pactado'
                              : 'Asocia una variante de producto al proveedor',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- SECCIÓN PROVEEDOR (Tarjeta de información) ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF6A1B29),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PROVEEDOR ASIGNADO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cargandoProveedorRemoto
                                ? 'Cargando proveedor...'
                                : (_nombreProveedorFijo.isNotEmpty
                                      ? _nombreProveedorFijo
                                      : 'Proveedor ID: ${_selectedProveedor ?? "N/D"}'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN VARIANTE ---
              varProvider.cargando
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF6A1B29),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<int>(
                      initialValue: varianteValor,
                      isExpanded: true,
                      items: varProvider.variantes.map((v) {
                        final nombreProd = v.nombreProducto ?? 'Producto';
                        final ml = v.mililitros ?? 0;
                        final sku = v.sku;

                        return DropdownMenuItem<int>(
                          value: v.id,
                          child: Text(
                            '$nombreProd — ${ml}ml  •  SKU: $sku',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (vId) {
                        setState(() {
                          _selectedVariante = vId;
                        });

                        if (vId != null) {
                          try {
                            final varianteSeleccionada = varProvider.variantes
                                .firstWhere((v) => v.id == vId);
                            _costoController.text = double.parse(
                              varianteSeleccionada.costoCompra.toString(),
                            ).toStringAsFixed(2);
                          } catch (_) {}
                        }
                      },
                      validator: (val) => val == null
                          ? 'Debe seleccionar una variante de producto'
                          : null,
                      decoration: _inputDecoration(
                        'Seleccionar Producto / Variante',
                        Icons.inventory_2_outlined,
                      ),
                    ),
              const SizedBox(height: 16),

              // --- CAMPO COSTO PACTADO ---
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
                  'Costo Pactado (\$)',
                  Icons.payments_outlined,
                ).copyWith(counterText: ''),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El costo pactado es obligatorio';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Ingrese un monto válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Botón de acción principal
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: esEdicion
                      ? 'Actualizar Vinculación'
                      : 'Vincular Producto',
                  isLoading: _cargando,
                  onPressed: _guardar,
                ),
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
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF6A1B29), size: 22),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6A1B29), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6A1B29), width: 2),
      ),
    );
  }
}
