import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/core/constants/app_strings.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/widgets/common/loading_indicator.dart';
import 'package:login_app/presentation/widgets/visitor/route_card.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({Key? key}) : super(key: key);

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
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
      appBar: AppBar(
        title: const Text(AppStrings.routes),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noData,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
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
              padding: const EdgeInsets.all(16),
              itemCount: routesProvider.routes.length,
              itemBuilder: (context, index) {
                return RouteCard(
                  route: routesProvider.routes[index],
                  onTap: () {
                    // Handle route selection
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
