import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/widgets/common/loading_indicator.dart';

class BusesManagementScreen extends StatefulWidget {
  const BusesManagementScreen({Key? key}) : super(key: key);

  @override
  State<BusesManagementScreen> createState() => _BusesManagementScreenState();
}

class _BusesManagementScreenState extends State<BusesManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoutesProvider>().fetchRoutes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestión de Buses'),
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A1428),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A1428)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RoutesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Cargando buses...');
          }

          // Filtramos rutas que tienen placa asignada
          final routesWithBus = provider.routes
              .where((r) => r.isActive)
              .toList();

          if (routesWithBus.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus, size: 56, color: AppColors.grey400),
                  const SizedBox(height: 12),
                  const Text('No hay rutas/buses registrados'),
                  const SizedBox(height: 8),
                  const Text(
                    'Las placas y conductores se gestionan\ndesde "Gestión de Rutas"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/routes-management'),
                    icon: const Icon(Icons.route),
                    label: const Text('Ir a Rutas'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: routesWithBus.length,
            itemBuilder: (context, index) {
              final route = routesWithBus[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.directions_bus_filled_rounded,
                        color: AppColors.secondary, size: 20),
                  ),
                  title: Text(
                    route.routeName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${route.startPoint} → ${route.endPoint}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Asientos: ${route.estimatedDuration ~/ 1} • \$${route.fare.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.primary, size: 18),
                    onPressed: () => Navigator.pushNamed(
                        context, '/routes-management'),
                    tooltip: 'Editar desde Rutas',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}