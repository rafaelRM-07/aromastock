import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../views/catalogos/catalogos_view.dart';
import '../../views/proveedores_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color wineRed = Color(0xFF4A1519);
    const Color softBackground = Color(0xFFF8F9FA);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE74C3C).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final perfil = auth.perfil;

              return ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    // CABECERA ESTILIZADA (Minimalista y elegante)
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(color: softBackground),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: wineRed.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person_rounded,
                                size: 30,
                                color: wineRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  perfil?.nombre ?? "Cargando...",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  perfil?.rol ?? "Usuario",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                    const SizedBox(height: 8),

                    // LISTA DE NAVEGACIÓN
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        children: [
                          _buildDrawerItem(
                            context: context,
                            icon: Icons.grid_view_rounded,
                            title: "Catálogos",
                            color: wineRed,
                            onTap: () async {
                              Navigator.pop(context);
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CatalogosView(),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          _buildDrawerItem(
                            context: context,
                            icon: Icons.local_shipping_rounded,
                            title: "Proveedores",
                            color: wineRed,
                            onTap: () async {
                              Navigator.pop(context);
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProveedoresView(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // BOTÓN CERRAR SESIÓN
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                        color: Colors.red.shade50.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: auth.cargando
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  auth.logout();
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                auth.cargando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.red,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                const SizedBox(width: 14),
                                const Text(
                                  "Cerrar Sesión",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
