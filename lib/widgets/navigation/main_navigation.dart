import 'package:flutter/material.dart';
import 'package:aromastock/views/home_view.dart';
import 'package:aromastock/views/productos_view.dart';
import 'package:aromastock/views/estadisticas_view.dart';
import 'package:aromastock/views/perfil_view.dart';
import 'package:aromastock/widgets/common/bottom_nav.dart';
import 'package:aromastock/widgets/common/app_drawer.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(), // 0
    EstadisticasView(), // 1
    ProductosView(), // 2
    PerfilView(), // 3
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.blur_on, size: 32, color: Color(0xFF6A1B29)),
            const SizedBox(width: 10),
            const Text(
              "AromaStock",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B29),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
