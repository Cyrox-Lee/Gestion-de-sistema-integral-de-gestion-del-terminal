import 'package:flutter/material.dart';
import 'package:login_app/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'modelos.dart';
import 'widgets_compartidos.dart';
import 'dialogo_flujo_reserva.dart';

class PantallaPrincipalVisitante extends StatefulWidget {
  const PantallaPrincipalVisitante({Key? key}) : super(key: key);

  @override
  State<PantallaPrincipalVisitante> createState() =>
      _PantallaPrincipalVisitanteState();
}

class _PantallaPrincipalVisitanteState
    extends State<PantallaPrincipalVisitante> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  late Map<int, bool> _seleccionAsientos;
  String _consulta = '';
  String? _idEmpresaSeleccionada;
  List<TransportCompany> _empresas = [];

  @override
  void initState() {
    super.initState();
    _idEmpresaSeleccionada = '1';
    _empresas = []; // Limpiar empresas previas
    _inicializarSeleccionAsientos();
    // Cargar rutas desde el API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutesProvider>().fetchRoutes();
    });
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _inicializarEmpresasConRutas(List<TransportRoute> rutas) {
    _empresas = [
      TransportCompany(
        id: '1',
        name: 'Macarena',
        description: 'Rutas intermunicipales',
        colorPrimary: const Color.fromARGB(255, 255, 145, 0),
        colorSecondary: const Color.fromARGB(255, 255, 123, 0),
        icon: Icons.directions_bus_filled_rounded,
        routes: rutas,
      ),
    ];
    _idEmpresaSeleccionada = '1';
    _inicializarSeleccionAsientos();
  }

  void _inicializarSeleccionAsientos() {
    _seleccionAsientos = {};
    if (_empresas.isNotEmpty && _empresaSeleccionada.routes.isNotEmpty) {
      for (int i = 0; i < _empresaSeleccionada.routes.first.totalSeats; i++) {
        _seleccionAsientos[i] = false;
      }
    }
  }

  TransportCompany get _empresaSeleccionada {
    if (_empresas.isEmpty) {
      return TransportCompany(
        id: '1',
        name: 'Macarena',
        description: '',
        colorPrimary: const Color.fromARGB(255, 255, 145, 0),
        colorSecondary: const Color.fromARGB(255, 255, 123, 0),
        icon: Icons.directions_bus_filled_rounded,
        routes: [],
      );
    }
    return _empresas.firstWhere((c) => c.id == _idEmpresaSeleccionada);
  }

  List<TransportRoute> get _rutasFiltradas {
    if (_empresas.isEmpty) return [];
    if (_consulta.trim().isEmpty) return _empresaSeleccionada.routes;
    return _empresaSeleccionada.routes.where((r) {
      return r.name.toLowerCase().contains(_consulta.toLowerCase()) ||
          r.origin.toLowerCase().contains(_consulta.toLowerCase()) ||
          r.destination.toLowerCase().contains(_consulta.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutesProvider>(
      builder: (context, routesProvider, _) {
        if (routesProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cargando rutas...'),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (routesProvider.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${routesProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      routesProvider.fetchRoutes();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final routeModels = routesProvider.routes;
        final transportRoutes = routeModels.map((route) {
          return TransportRoute(
            id: int.tryParse(route.id),
            name: route.routeName,
            origin: route.startPoint,
            destination: route.endPoint,
            schedule: '08:00 AM',
            estimatedTime: _calculateEstimatedTime(route.estimatedDuration),
            driverName: 'Conductor disponible',
            vehiclePlate: 'Por asignar',
            availableSeats: 14,
            totalSeats: 14,
            price: route.fare.toInt(),
          );
        }).toList();

        // Actualizar empresas con las rutas del API (siempre)
        _inicializarEmpresasConRutas(transportRoutes);

        return Scaffold(
          appBar: _construirBarraAplicacion(),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetsCompartidos.construirTarjetaBienvenida(),
                      const SizedBox(height: 20),
                      WidgetsCompartidos.construirCampoBusqueda(
                        _controladorBusqueda,
                        (v) => setState(() => _consulta = v),
                      ),
                      const SizedBox(height: 20),
                      WidgetsCompartidos.construirEtiquetaSeccion(
                        'Macarena',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _construirGridEmpresas()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirEncabezadoRutas(),
                      const SizedBox(height: 12),
                      _construirListaRutas(),
                      const SizedBox(height: 20),
                      WidgetsCompartidos.construirEtiquetaSeccion(
                        'Consejos de viaje',
                      ),
                      const SizedBox(height: 12),
                      WidgetsCompartidos.construirTarjetaTarjeta(
                        icono: Icons.access_time_rounded,
                        titulo: 'Revisa horarios en tiempo real',
                        subtitulo: 'Disponibilidad actualizada al instante.',
                        color: const Color(0xFF0EA5E9),
                      ),
                      const SizedBox(height: 10),
                      WidgetsCompartidos.construirTarjetaTarjeta(
                        icono: Icons.notifications_rounded,
                        titulo: 'Activa notificaciones',
                        subtitulo: 'Alertas de retrasos y cambios de ruta.',
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calculateEstimatedTime(int durationMinutes) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  PreferredSizeWidget _construirBarraAplicacion() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: const Text(
        'Mi Transporte',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            tooltip: 'Cerrar sesión',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _construirGridEmpresas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _empresas.asMap().entries.map((e) {
            final empresa = e.value;
            final estaSeleccionada = empresa.id == _idEmpresaSeleccionada;
            return Padding(
              padding: EdgeInsets.only(
                right: e.key == _empresas.length - 1 ? 0 : 10,
              ),
              child: GestureDetector(
                onTap: () => setState(() {
                  _idEmpresaSeleccionada = empresa.id;
                  _controladorBusqueda.clear();
                  _consulta = '';
                  _inicializarSeleccionAsientos();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: estaSeleccionada
                        ? LinearGradient(
                            colors: [
                              empresa.colorPrimary,
                              empresa.colorSecondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !estaSeleccionada ? Colors.grey[100] : null,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: estaSeleccionada
                        ? [
                            BoxShadow(
                              color: empresa.colorPrimary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        empresa.icon,
                        size: 35,
                        color: estaSeleccionada
                            ? Colors.white
                            : empresa.colorPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        empresa.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              estaSeleccionada ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        empresa.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: estaSeleccionada
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirEncabezadoRutas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_rutasFiltradas.length} ruta(s) disponible(s)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ordenar por',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Precio (menor a mayor)'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _empresaSeleccionada.routes.sort(
                            (a, b) => a.price.compareTo(b.price),
                          );
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Precio (mayor a menor)'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _empresaSeleccionada.routes.sort(
                            (a, b) => b.price.compareTo(a.price),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.sort_by_alpha_rounded,
              color: Color(0xFF0EA5E9),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirListaRutas() {
    if (_rutasFiltradas.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                'No se encontraron rutas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rutasFiltradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final ruta = _rutasFiltradas[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => goFlujoReserva(
                empresa: _empresaSeleccionada,
                ruta: ruta,
                alConfirmar: (asientos) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reserva confirmada: $asientos')),
                  );
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ruta.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ruta.origin} → ${ruta.destination}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${ruta.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ruta.schedule,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ruta.estimatedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ruta.availableSeats}/${ruta.totalSeats}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
