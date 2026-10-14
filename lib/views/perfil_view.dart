import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  void initState() {
    super.initState();
    // Invocamos la carga del perfil al entrar a la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().cargarPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color wineRed = Color(0xFF4A0E0E);
    // Escuchamos el estado del provider
    final auth = context.watch<AuthProvider>();
    final perfil = auth.perfil;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: auth.cargando
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(wineRed),
              ),
            )
          : perfil == null
          ? const Center(child: Text("No se pudo cargar el perfil"))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Título integrado limpia y elegantemente sin AppBar
                    const Text(
                      "Perfil",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar superior con sombra elegante
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE74C3C).withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: wineRed,
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contenedor tipo tarjeta moderna que agrupa la información original
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE74C3C).withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF1F3F5)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.person_outline_rounded,
                            title: "Nombre",
                            value: perfil.nombre,
                            iconColor: wineRed,
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0xFFF1F3F5),
                            indent: 16,
                            endIndent: 16,
                          ),
                          _buildInfoTile(
                            icon: Icons.badge_outlined,
                            title: "Rol de usuario",
                            value: perfil.rol,
                            iconColor: wineRed,
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0xFFF1F3F5),
                            indent: 16,
                            endIndent: 16,
                          ),
                          _buildStatusTile(perfil.activo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón de Cerrar Sesión estilizado
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: wineRed,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: wineRed.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: auth.cargando ? null : () => auth.logout(),
                        child: auth.cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Cerrar Sesión",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
    );
  }

  Widget _buildStatusTile(bool isActive) {
    final Color statusColor = isActive
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.gpp_bad_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estado",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? "Activo" : "Inactivo",
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
