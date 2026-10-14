import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color wineRed = Color(0xFF4A0E0E);

    return const Scaffold(
      backgroundColor: Color(
        0xFFF8FAFC,
      ), // Un tono gris muy claro, no blanco puro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(wineRed),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              "Cargando AromaStock...",
              style: TextStyle(
                color:
                    wineRed, // Usamos tu color principal para el texto también
                fontSize: 14,
                letterSpacing: 1.2, // Un toque extra de profesionalismo
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
