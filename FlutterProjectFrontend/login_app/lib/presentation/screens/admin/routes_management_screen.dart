import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_colors.dart';
import 'package:login_app/core/constants/app_strings.dart';
import 'package:login_app/core/utils/validators.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/widgets/common/custom_text_field.dart';
import 'package:login_app/presentation/widgets/common/loading_indicator.dart';

class RoutesManagementScreen extends StatefulWidget {
  const RoutesManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoutesManagementScreen> createState() =>
      _RoutesManagementScreenState();
}

class _RoutesManagementScreenState extends State<RoutesManagementScreen> {
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
        title: const Text(AppStrings.routesManagement),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRouteDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
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
                  const Text('No hay rutas registradas'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRouteDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Primera Ruta'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
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
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Editar', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          onTap: () => _showEditRouteDialog(context, route),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          onTap: () => _showDeleteConfirmation(
                            context,
                            routesProvider,
                            route.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddRouteDialog(BuildContext context) {
  final routeNameController = TextEditingController();
  final routeNumberController = TextEditingController();
  final startPointController = TextEditingController();
  final endPointController = TextEditingController();
  final fareController = TextEditingController();
  final durationController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  
  // Capturar el provider ANTES de abrir el diálogo
  final routesProvider = context.read<RoutesProvider>();

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (ctx, setState) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Agregar Ruta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1428),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                            label: 'Nombre de ruta',
                            controller: routeNameController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Número de ruta',
                            controller: routeNumberController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Punto de inicio',
                            controller: startPointController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Punto final',
                            controller: endPointController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Tarifa',
                            controller: fareController,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateNumber,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Duración (minutos)',
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateNumber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setState(() => isLoading = true);

                                try {
                                  final success = await routesProvider.createRoute(
                                    routeName: routeNameController.text.trim(),
                                    routeNumber: routeNumberController.text.trim(),
                                    startPoint: startPointController.text.trim(),
                                    endPoint: endPointController.text.trim(),
                                    fare: double.parse(fareController.text.trim()),
                                    estimatedDuration: int.parse(durationController.text.trim()),
                                    description: '',
                                  );

                                  if (success) {
                                    await routesProvider.fetchRoutes();
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(
                                          content: Text('✅ Ruta agregada exitosamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    setState(() => isLoading = false);
                                    if (dialogContext.mounted) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Error: ${routesProvider.errorMessage ?? "Error desconocido"}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  if (dialogContext.mounted) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  void _showEditRouteDialog(BuildContext context, dynamic route) {
    final routeNameController = TextEditingController(text: route.routeName);
    final routeNumberController =
        TextEditingController(text: route.routeNumber);
    final startPointController =
        TextEditingController(text: route.startPoint);
    final endPointController = TextEditingController(text: route.endPoint);
    final fareController = TextEditingController(text: route.fare.toString());
    final durationController = TextEditingController(
        text: route.estimatedDuration.toString());
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          AppStrings.editRoute,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1428),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                            label: AppStrings.routeName,
                            controller: routeNameController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: AppStrings.routeNumber,
                            controller: routeNumberController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: AppStrings.startPoint,
                            controller: startPointController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: AppStrings.endPoint,
                            controller: endPointController,
                            validator: Validators.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Tarifa',
                            controller: fareController,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateNumber,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Duración (minutos)',
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateNumber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          AppStrings.cancel,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  try {
                                    final routesProv = context.read<RoutesProvider>();

                                    await routesProv.updateRoute(
                                          id: route.id,
                                          routeName: routeNameController.text,
                                          routeNumber: routeNumberController.text,
                                          startPoint: startPointController.text,
                                          endPoint: endPointController.text,
                                          fare: double.parse(fareController.text),
                                          estimatedDuration: int.parse(durationController.text),
                                        );

                                    // Hacer refresh desde el servidor para sincronizar
                                    await routesProv.fetchRoutes();

                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(
                                            content: Text('Ruta actualizada exitosamente')),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (dialogContext.mounted) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(AppStrings.save),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, RoutesProvider routesProvider, String routeId) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Eliminar Ruta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1428),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Estás seguro de que deseas eliminar esta ruta?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Esta acción no se puede deshacer.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        AppStrings.cancel,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await routesProvider.deleteRoute(routeId);
                          if (dialogContext.mounted) {
                            // Hacer refresh desde el servidor para sincronizar
                            await routesProvider.fetchRoutes();
                            
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content: Text('Ruta eliminada exitosamente')),
                            );
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text(
                        AppStrings.delete,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
