import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/productos_model.dart';
import '../../data/providers/categoria_provider.dart';
import '../../data/providers/concentraciones_provider.dart';
import '../../data/providers/familia_olfativa_provider.dart';
import '../../data/providers/galerias_provider.dart';
import '../../data/providers/marcas_provider.dart';
import '../../data/providers/productos_provider.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class ProductoForm extends StatefulWidget {
  final ProductoModel? producto;

  const ProductoForm({super.key, this.producto});

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  int? _marcaIdSeleccionada;
  int? _categoriaIdSeleccionada;
  int? _concentracionIdSeleccionada;
  int? _familiaOlfativaIdSeleccionada;

  String? _ocasionSeleccionada;
  String? _estacionSeleccionada;

  final List<String> _listaOcasiones = [
    'Casual',
    'Formal',
    'Noche',
    'Fiesta',
    'Oficina',
    'Romántica',
    'Deporte',
  ];

  final List<String> _listaEstaciones = [
    'Invierno',
    'Verano',
    'Primavera',
    'Otoño',
    'Todo el año',
  ];

  File? _imagenPrincipalLocal;
  final List<File> _galeriaLocales = [];

  bool _cargando = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.producto?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.producto?.descripcion ?? '',
    );

    _ocasionSeleccionada =
        widget.producto?.ocasion != null &&
            _listaOcasiones.contains(widget.producto?.ocasion)
        ? widget.producto?.ocasion
        : null;

    _estacionSeleccionada =
        widget.producto?.estacion != null &&
            _listaEstaciones.contains(widget.producto?.estacion)
        ? widget.producto?.estacion
        : null;

    _marcaIdSeleccionada = widget.producto?.marcaId;
    _categoriaIdSeleccionada = widget.producto?.categoriaId;
    _concentracionIdSeleccionada = widget.producto?.concentracionId;
    _familiaOlfativaIdSeleccionada = widget.producto?.familiaOlfativaId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarcaProvider>().cargarMarcas();
      context.read<CategoriaProvider>().cargarCategorias();
      context.read<ConcentracionProvider>().cargar();
      context.read<FamiliaOlfativaProvider>().cargar();

      if (widget.producto?.id != null) {
        context.read<GaleriaProvider>().cargarPorProducto(widget.producto!.id!);
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagenPrincipal() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagenPrincipalLocal = File(picked.path));
    }
  }

  Future<void> _agregarImagenGaleria() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (widget.producto?.id != null) {
      if (!mounted) return;
      final galeriaProv = context.read<GaleriaProvider>();
      await galeriaProv.subirImagen(widget.producto!.id!, File(picked.path));
    } else {
      setState(() {
        _galeriaLocales.add(File(picked.path));
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final prodProvider = context.read<ProductoProvider>();
    final galeriaProvider = context.read<GaleriaProvider>();

    final productoData = ProductoModel(
      id: widget.producto?.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isNotEmpty
          ? _descripcionController.text.trim()
          : null,
      ocasion: _ocasionSeleccionada,
      estacion: _estacionSeleccionada,
      marcaId: _marcaIdSeleccionada,
      categoriaId: _categoriaIdSeleccionada,
      concentracionId: _concentracionIdSeleccionada,
      familiaOlfativaId: _familiaOlfativaIdSeleccionada,
      imagenPrincipal: widget.producto?.imagenPrincipal,
    );

    if (widget.producto == null) {
      final nuevoProducto = await prodProvider.crearProducto(
        productoData,
        _imagenPrincipalLocal,
      );

      if (nuevoProducto != null && nuevoProducto.id != null) {
        for (var file in _galeriaLocales) {
          await galeriaProvider.subirImagen(nuevoProducto.id!, file);
        }
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarError(prodProvider.error ?? 'Error al guardar el producto');
      }
    } else {
      final exito = await prodProvider.editarProducto(
        productoData,
        _imagenPrincipalLocal,
      );
      if (mounted) {
        if (exito) {
          Navigator.pop(context);
        } else {
          _mostrarError(prodProvider.error ?? 'Error al editar el producto');
        }
      }
    }

    if (mounted) setState(() => _cargando = false);
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;
    final galeriaProv = context.watch<GaleriaProvider>();
    final marcaProv = context.watch<MarcaProvider>();
    final categoriaProv = context.watch<CategoriaProvider>();
    final concentracionProv = context.watch<ConcentracionProvider>();
    final familiaProv = context.watch<FamiliaOlfativaProvider>();

    final marcaValor = marcaProv.lista.any((m) => m.id == _marcaIdSeleccionada)
        ? _marcaIdSeleccionada
        : null;
    final categoriaValor =
        categoriaProv.lista.any((c) => c.id == _categoriaIdSeleccionada)
        ? _categoriaIdSeleccionada
        : null;
    final concentracionValor =
        concentracionProv.lista.any((c) => c.id == _concentracionIdSeleccionada)
        ? _concentracionIdSeleccionada
        : null;
    final familiaValor =
        familiaProv.lista.any((f) => f.id == _familiaOlfativaIdSeleccionada)
        ? _familiaOlfativaIdSeleccionada
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              esEdicion ? 'Editar Producto' : 'Nuevo Producto',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- IMAGEN PRINCIPAL ---
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imagenPrincipalLocal != null
                          ? Image.file(
                              _imagenPrincipalLocal!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                          : (widget.producto?.imagenPrincipal != null
                                ? Image.network(
                                    widget.producto!.imagenPrincipal!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  )),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _seleccionarImagenPrincipal,
                    icon: const Icon(Icons.upload, color: Color(0xFF6A1B29)),
                    label: const Text(
                      'Imagen Principal',
                      style: TextStyle(color: Color(0xFF6A1B29)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- CAMPOS DEL FORMULARIO ---
            CustomTextField(
              controller: _nombreController,
              label: 'Nombre del Producto',
              icon: Icons.shopping_bag,
              keyboardType: TextInputType.text,
              maxLength: 30,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]'),
                ),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (v.trim().length > 30) {
                  return 'Máximo 30 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: marcaValor,
              items: marcaProv.lista
                  .map(
                    (m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _marcaIdSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La marca es obligatoria' : null,
              decoration: _dropdownDecoration(
                'Marca / Casa Perfumista',
                Icons.branding_watermark,
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: categoriaValor,
              items: categoriaProv.lista
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  )
                  .toList(),
              onChanged: (val) =>
                  setState(() => _categoriaIdSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La categoría es obligatoria' : null,
              decoration: _dropdownDecoration('Categoría', Icons.category),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: concentracionValor,
              items: concentracionProv.lista
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  )
                  .toList(),
              onChanged: (val) =>
                  setState(() => _concentracionIdSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La concentración es obligatoria' : null,
              decoration: _dropdownDecoration('Concentración', Icons.science),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: familiaValor,
              items: familiaProv.lista
                  .map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.nombre)),
                  )
                  .toList(),
              onChanged: (val) =>
                  setState(() => _familiaOlfativaIdSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La familia olfativa es obligatoria' : null,
              decoration: _dropdownDecoration(
                'Familia Olfativa',
                Icons.local_florist,
              ),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _descripcionController,
              label: 'Descripción del Perfume',
              icon: Icons.description,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.,;()¿?¡!-]'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _ocasionSeleccionada,
              items: _listaOcasiones
                  .map(
                    (ocasion) =>
                        DropdownMenuItem(value: ocasion, child: Text(ocasion)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _ocasionSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La ocasión es obligatoria' : null,
              decoration: _dropdownDecoration('Ocasión', Icons.event),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _estacionSeleccionada,
              items: _listaEstaciones
                  .map(
                    (estacion) => DropdownMenuItem(
                      value: estacion,
                      child: Text(estacion),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _estacionSeleccionada = val),
              validator: (val) =>
                  val == null ? 'La estación es obligatoria' : null,
              decoration: _dropdownDecoration(
                'Estación Recomendada',
                Icons.wb_sunny,
              ),
            ),
            const SizedBox(height: 20),

            // --- GALERÍA DE FOTOS ---
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Galería de Fotos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _agregarImagenGaleria,
                  icon: const Icon(Icons.add_a_photo, color: Color(0xFF6A1B29)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // RENDERIZADO DE GALERÍA
            if (esEdicion)
              galeriaProv.cargando
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 85,
                      child: galeriaProv.imagenes.isEmpty
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'No hay imágenes adicionales',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: galeriaProv.imagenes.length,
                              itemBuilder: (context, index) {
                                final img = galeriaProv.imagenes[index];
                                final urlImagen = img.rutaImagen;

                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 80,
                                  height: 80,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          urlImagen,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (img.id != null) {
                                              galeriaProv.borrarImagen(
                                                img.id!,
                                                widget.producto!.id!,
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    )
            else
              SizedBox(
                height: 85,
                child: _galeriaLocales.isEmpty
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Añada fotos opcionales para la galería',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galeriaLocales.length,
                        itemBuilder: (context, index) {
                          final file = _galeriaLocales[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _galeriaLocales.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

            const SizedBox(height: 20),

            // BOTÓN GUARDAR
            CustomButton(
              text: esEdicion ? 'Actualizar Producto' : 'Guardar Producto',
              isLoading: _cargando,
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
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
