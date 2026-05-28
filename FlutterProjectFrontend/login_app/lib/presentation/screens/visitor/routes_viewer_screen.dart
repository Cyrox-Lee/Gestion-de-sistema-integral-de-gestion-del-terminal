import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/widgets/common/loading_indicator.dart';

class RoutesViewerScreen extends StatefulWidget {
  const RoutesViewerScreen({Key? key}) : super(key: key);

  @override
  State<RoutesViewerScreen> createState() => _RoutesViewerScreenState();
}

class _RoutesViewerScreenState extends State<RoutesViewerScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar rutas cuando se abre la pantalla
    Future.microtask(() {
      context.read<RoutesProvider>().fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Rutas Disponibles'),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A1428),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A1428)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0A1428)),
            onPressed: () {
              context.read<RoutesProvider>().fetchRoutes();
            },
          ),
        ],
      ),
      body: Consumer<RoutesProvider>(
        builder: (context, routesProvider, _) {
          if (routesProvider.isLoading && routesProvider.routes.isEmpty) {
            return const LoadingIndicator(message: 'Cargando rutas...');
          }

          if (routesProvider.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.route,
                    size: 56,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 12),
                  const Text('No hay rutas disponibles'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      routesProvider.fetchRoutes();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recargar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => routesProvider.fetchRoutes(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: routesProvider.routes.length,
              itemBuilder: (context, index) {
                final route = routesProvider.routes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        route.routeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${route.startPoint} → ${route.endPoint}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$ ${route.fare.toStringAsFixed(0)} • ${route.estimatedDuration} min',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                          if (route.description != null && route.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                route.description!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: route.isActive
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          route.isActive ? 'Activa' : 'Inactiva',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: route.isActive
                                ? const Color(0xFF10B981)
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
