import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos el color wine-red solicitado
    const Color wineRed = Color(0xFF4A0E0E);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.white.withValues(
              alpha: 0.7,
            ), // Fondo más claro y minimalista
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(wineRed),
              ),
            ),
          ),
      ],
    );
  }
}
