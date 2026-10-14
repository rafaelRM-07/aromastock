import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class RecoveryPasswordView extends StatefulWidget {
  const RecoveryPasswordView({super.key});

  @override
  State<RecoveryPasswordView> createState() => _RecoveryPasswordViewState();
}

class _RecoveryPasswordViewState extends State<RecoveryPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Dentro de _RecoveryPasswordViewState
  void _enviarEmailRecuperacion() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Llamamos a la función del provider que ya creamos
      await authProvider.resetPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revisa tu correo para las instrucciones.'),
            backgroundColor: Colors.green, // Color de éxito
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Regresa al login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar el correo. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6A1B29)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: Color(0xFF6A1B29),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa tu correo y te enviaremos los pasos para recuperarla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => (val == null || !val.contains('@'))
                        ? 'Ingresa un correo válido'
                        : null,
                  ),
                  const SizedBox(height: 30),

                  CustomButton(
                    text: 'Enviar instrucciones',
                    isLoading: authCargando,
                    onPressed: _enviarEmailRecuperacion,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
