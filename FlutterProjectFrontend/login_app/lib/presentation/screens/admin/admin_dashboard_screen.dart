import 'package:flutter/material.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/core/constants/app_strings.dart';
import 'package:login_app/presentation/widgets/admin/stat_card.dart';
import 'package:login_app/presentation/widgets/admin/quick_action_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildModernAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 10),
              _buildCompaniesSection(),
              const SizedBox(height: 10),
              _buildStatsSection(),
              const SizedBox(height: 10),
              _buildManagementSection(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF6F5AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
          ),
        ),
      ),
      title: const Text(
        'Panel Admin',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0A1428),
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.primary),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0A1428),
                Color(0xFF1C2A4A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF6F5AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Bienvenido, Administrador!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gestiona tu plataforma',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D9FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1428),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.4,
            children: [
              _buildAnimatedStatCard(
                index: 0,
                title: AppStrings.routes,
                value: '12',
                icon: Icons.route,
                iconColor: AppColors.primary,
              ),
              _buildAnimatedStatCard(
                index: 1,
                title: AppStrings.buses,
                value: '24',
                icon: Icons.directions_bus,
                iconColor: AppColors.secondary,
              ),
              _buildAnimatedStatCard(
                index: 2,
                title: AppStrings.drivers,
                value: '18',
                icon: Icons.person,
                iconColor: AppColors.success,
              ),
              _buildAnimatedStatCard(
                index: 3,
                title: AppStrings.schedules,
                value: '45',
                icon: Icons.schedule,
                iconColor: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required int index,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.08),
            0.6 + (index * 0.08),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: StatCard(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
        onTap: () {
          if (title == AppStrings.routes) {
            Navigator.pushNamed(context, '/routes-management');
          } else if (title == AppStrings.buses) {
            Navigator.pushNamed(context, '/buses-management');
          } else if (title == AppStrings.drivers) {
            Navigator.pushNamed(context, '/drivers-management');
          } else if (title == AppStrings.schedules) {
            Navigator.pushNamed(context, '/schedules-management');
          }
        },
      ),
    );
  }

  Widget _buildManagementSection() {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1428),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 2.8,
            children: [
              _buildCompactQuickActionItem(
                index: 0,
                icon: Icons.route,
                label: 'Rutas',
                count: '12',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/routes-management'),
              ),
              _buildCompactQuickActionItem(
                index: 1,
                icon: Icons.directions_bus,
                label: 'Buses',
                count: '24',
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, '/buses-management'),
              ),
              _buildCompactQuickActionItem(
                index: 2,
                icon: Icons.person,
                label: 'Conductores',
                count: '18',
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, '/drivers-management'),
              ),
              _buildCompactQuickActionItem(
                index: 3,
                icon: Icons.schedule,
                label: 'Horarios',
                count: '45',
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, '/schedules-management'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactQuickActionItem({
    required int index,
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.45 + (index * 0.08),
            0.75 + (index * 0.08),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: QuickActionCard(
        icon: icon,
        label: label,
        count: count,
        color: color,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCompaniesSection() {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Empresas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1428),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              itemBuilder: (context, index) {
                // TODO: Conectar con servicio de empresas cuando la BD esté lista
                return _buildCompanyCard(
                  name: 'Macarena',
                  description: 'Rutas intermunicipales',
                  color: const Color.fromARGB(255, 255, 145, 0),
                  icon: Icons.directions_bus_filled_rounded,
                  onTap: () {
                    // Navegar a detalles de la empresa
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard({
    required String name,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withValues(alpha: 0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,        // ← fix overflow 5px
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 4),           // ← reemplaza spaceBetween
            Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1428),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              description,
              style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

