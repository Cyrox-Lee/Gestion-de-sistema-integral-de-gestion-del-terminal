import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/widgets/common/loading_indicator.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({Key? key}) : super(key: key);

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoutesProvider>().fetchRoutes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Disponibles'),
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
            return const LoadingIndicator(message: 'Cargando horarios...');
          }
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage ?? 'Error cargando horarios'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchRoutes(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final routes = provider.routes.where((r) => r.isActive).toList();

          if (routes.isEmpty) {
            return const Center(child: Text('No hay horarios disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: AppColors.warning, size: 20),
                  ),
                  title: Text(route.routeName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${route.startPoint} → ${route.endPoint} • ${route.estimatedDuration} min',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '\$${route.fare.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
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