import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'modelos.dart';
import 'widgets_compartidos.dart';
import 'package:login_app/presentation/providers/booking_provider.dart';

class goFlujoReserva extends StatefulWidget {
  final TransportCompany empresa;
  final TransportRoute ruta;
  final Function(List<int>) alConfirmar;

  const goFlujoReserva({
    Key? key,
    required this.empresa,
    required this.ruta,
    required this.alConfirmar,
  }) : super(key: key);

  @override
  State<goFlujoReserva> createState() => _goFlujoReservaState();
}

class _goFlujoReservaState extends State<goFlujoReserva> {
  late PageController _controladorPagina;
  int _pasoActual = 0;
  late Set<int> _asientosSeleccionados;
  late Map<int, bool> _asientosOcupados;
  late TextEditingController _controladorNombre;
  late TextEditingController _controladorTelefono;
  late TextEditingController _controladorEmail;

  @override
void initState() {
  super.initState();
  _controladorPagina = PageController();
  _asientosSeleccionados = {};
  _asientosOcupados = {};
  // Inicializar todos como disponibles (la API los actualizará)
  for (int i = 0; i < widget.ruta.totalSeats; i++) {
    _asientosOcupados[i] = false;
  }
  _controladorNombre = TextEditingController();
  _controladorTelefono = TextEditingController();
  _controladorEmail = TextEditingController();
  
  // ✅ Cargar asientos DESPUÉS de que el widget se haya construido
  // Evita el error "setState() called during build"
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _cargarAsientosDisponibles();
  });
}

Future<void> _cargarAsientosDisponibles() async {
  final routeId = (widget.ruta.id ?? 1).toString();
  final bookingProvider = context.read<BookingProvider>();
  await bookingProvider.loadAvailableSeats(routeId);

  if (!mounted) return;

  final asientosDisponibles = bookingProvider.availableSeats;
  setState(() {
    // Marcar todos como ocupados primero
    for (int i = 0; i < widget.ruta.totalSeats; i++) {
      _asientosOcupados[i] = true;
    }
    // Desmarcar los que sí están disponibles (la API devuelve números 1-indexed)
    for (int numero in asientosDisponibles) {
      final indice = numero - 1; // convertir a 0-indexed
      if (indice >= 0 && indice < widget.ruta.totalSeats) {
        _asientosOcupados[indice] = false;
      }
    }
  });
}

  bool get _esFormularioValido =>
      _validarNombre() == null &&
      _validarTelefono() == null &&
      _validarEmail() == null;

  String? _validarNombre() {
    final nombre = _controladorNombre.text.trim();
    if (nombre.isEmpty) {
      return 'El nombre es requerido';
    }
    if (nombre.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(nombre)) {
      return 'El nombre solo debe contener letras y espacios';
    }
    return null;
  }

  String? _validarTelefono() {
    final telefono = _controladorTelefono.text.trim();
    if (telefono.isEmpty) {
      return 'El teléfono es requerido';
    }
    final soloNumeros = telefono.replaceAll(RegExp(r'[^\d]'), '');
    if (soloNumeros.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(soloNumeros)) {
      return 'El teléfono solo puede contener números';
    }
    return null;
  }

  String? _validarEmail() {
    final email = _controladorEmail.text.trim();
    if (email.isEmpty) {
      return 'El correo es requerido';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Correo inválido';
    }
    return null;
  }

  int get _precioTotal => widget.ruta.price * _asientosSeleccionados.length;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            _construirEncabezado(),
            Expanded(
              child: PageView(
                controller: _controladorPagina,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _construirPasoDatos(),
                  _construirPasoAsientos(),
                  _construirPasoConfirmacion(),
                ],
              ),
            ),
            _construirBotones(),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.empresa.colorPrimary,
            widget.empresa.colorSecondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.empresa.icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ruta.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Paso ${_pasoActual + 1} de 3',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _construirBotones() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_pasoActual > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _irAlPasoAnterior,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2E8F0),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (_pasoActual > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _puedeAvanzar() ? _irAlSiguientePaso : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.empresa.colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _pasoActual == 2 ? 'Confirmar' : 'Siguiente',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPasoDatos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Pasajero',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _construirTarjetaInfo(
            widget.ruta.schedule,
            'Hora de salida',
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          _construirTarjetaInfo(
            widget.ruta.estimatedTime,
            'Tiempo estimado',
            Icons.timer_rounded,
          ),
          const SizedBox(height: 12),
          _construirTarjetaInfo(
            '\$${widget.ruta.price.toString()}',
            'Precio por pasaje',
            Icons.local_offer_rounded,
          ),
          const SizedBox(height: 24),
          const Text(
            'Tus datos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
           _construirCampoTexto(
             _controladorNombre,
             'Nombre completo',
             Icons.person_rounded,
             'Juan Pérez',
             _validarNombre,
           ),
          const SizedBox(height: 12),
           _construirCampoTexto(
             _controladorTelefono,
             'Teléfono',
             Icons.phone_rounded,
             '3001234567',
             _validarTelefono,
           ),
          const SizedBox(height: 12),
           _construirCampoTexto(
             _controladorEmail,
             'Email',
             Icons.email_rounded,
             'juan@email.com',
             _validarEmail,
           ),
        ],
      ),
    );
  }

  Widget _construirPasoAsientos() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tus asientos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona ${widget.ruta.availableSeats} asientos disponibles',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        if (context.watch<BookingProvider>().isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    'Cargando disponibilidad...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _construirVisualizacionBus(),
          const SizedBox(height: 20),
          _construirLeyendaAsientos(),
          const SizedBox(height: 16),
          _construirEstadisticasAsientos(),
        ],
      ],
    ),
  );
}

  Widget _construirPasoConfirmacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirmación de Reserva',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.empresa.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.empresa.colorPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_bus_rounded,
                      color: widget.empresa.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ruta.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${widget.ruta.origin} → ${widget.ruta.destination}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Hora de salida',
            widget.ruta.schedule,
          ),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Pasajero',
            _controladorNombre.text,
          ),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Teléfono',
            _controladorTelefono.text,
          ),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Email',
            _controladorEmail.text,
          ),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Asientos',
            _asientosSeleccionados.map((e) => '${e + 1}').join(', '),
          ),
          const Divider(height: 24),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Costo por pasaje',
            '\$${widget.ruta.price}',
            tamanoFuente: 13,
          ),
          WidgetsCompartidos.construirFilaConfirmacion(
            'Cantidad de asientos',
            '${_asientosSeleccionados.length}',
            tamanoFuente: 13,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: widget.empresa.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL A PAGAR',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                Text(
                  '\$${_precioTotal}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: widget.empresa.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVisualizacionBus() {
    return Center(
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.empresa.colorPrimary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.empresa.colorPrimary.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
          child: Column(
            children: [
              // ── Fila delantera: conductor + acompañante ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Conductor
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.empresa.colorPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.empresa.colorPrimary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.drive_eta_rounded,
                      color: widget.empresa.colorPrimary,
                      size: 22,
                    ),
                  ),
                  // Pasillo delantera
                  const SizedBox(width: 16),
                  Container(
                    width: 2,
                    height: 48,
                    color: widget.empresa.colorPrimary.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 16),
                  // Acompañante derecho
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: widget.empresa.colorPrimary.withValues(alpha: 0.2),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              // ── Filas de pasajeros ──
              _construirFilaBus([0, 1, 2, 3]),
              const SizedBox(height: 10),
              _construirFilaBus([4, 5, 6, 7]),
              const SizedBox(height: 10),
              _construirFilaBus([8, 9, 10, 11]),
              const SizedBox(height: 16),
              Divider(
                color: widget.empresa.colorPrimary.withValues(alpha: 0.2),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              // ── Fila trasera: 5 asientos pegados ──
              if (widget.ruta.totalSeats > 12)
                _construirFilaTrasera([12, 13, 14, 15, 16])
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirFilaBus(List<int> indicesAsientos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            _construirAsientoBus(indicesAsientos[0]),
            const SizedBox(width: 6),
            _construirAsientoBus(indicesAsientos[1]),
          ],
        ),
        const SizedBox(width: 16),
        Container(
          width: 2,
          height: 40,
          color: widget.empresa.colorPrimary.withValues(alpha: 0.2),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            _construirAsientoBus(indicesAsientos[2]),
            const SizedBox(width: 6),
            _construirAsientoBus(indicesAsientos[3]),
          ],
        ),
      ],
    );
  }

  // Fila trasera: 5 asientos seguidos pegados
  Widget _construirFilaTrasera(List<int> indicesAsientos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicesAsientos.asMap().entries.map((e) {
        return Row(
          children: [
            _construirAsientoBus(e.value),
            if (e.key < indicesAsientos.length - 1)
              const SizedBox(width: 4),
          ],
        );
      }).toList(),
    );
  }

  Widget _construirAsientoBus(int indice) {
    final estaOcupado = _asientosOcupados[indice] ?? false;
    final estaSeleccionado = _asientosSeleccionados.contains(indice);

    return GestureDetector(
      onTap: estaOcupado
          ? null
          : () => setState(() {
                if (estaSeleccionado) {
                  _asientosSeleccionados.remove(indice);
                } else {
                  // Usar el conteo real de asientos libres determinado por
                  // _asientosOcupados en lugar de widget.ruta.availableSeats.
                  final libres = _asientosOcupados.values.where((v) => !v).length;
                  if (_asientosSeleccionados.length < libres) {
                    _asientosSeleccionados.add(indice);
                  }
                }
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: estaOcupado
              ? const Color(0xFFE2E8F0)
              : estaSeleccionado
              ? widget.empresa.colorPrimary
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: estaOcupado
                ? const Color(0xFF94A3B8)
                : estaSeleccionado
                ? widget.empresa.colorPrimary
                : widget.empresa.colorPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: estaSeleccionado
              ? [
                  BoxShadow(
                    color: widget.empresa.colorPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estaOcupado
                  ? Icons.person_rounded
                  : estaSeleccionado
                  ? Icons.check_circle_rounded
                  : Icons.event_seat_rounded,
              color: estaOcupado
                  ? const Color(0xFF94A3B8)
                  : estaSeleccionado
                  ? Colors.white
                  : widget.empresa.colorPrimary.withValues(alpha: 0.6),
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              '${indice + 1}',
              style: TextStyle(
                color: estaOcupado
                    ? const Color(0xFF94A3B8)
                    : estaSeleccionado
                    ? Colors.white
                    : widget.empresa.colorPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLeyendaAsientos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _construirElementoLeyenda(
          Colors.white,
          widget.empresa.colorPrimary.withValues(alpha: 0.3),
          'Disponible',
        ),
        const SizedBox(width: 20),
        _construirElementoLeyenda(
          const Color(0xFFE2E8F0),
          const Color(0xFF94A3B8),
          'Ocupado',
        ),
        const SizedBox(width: 20),
        _construirElementoLeyenda(
          widget.empresa.colorPrimary,
          widget.empresa.colorPrimary,
          'Seleccionado',
        ),
      ],
    );
  }

  Widget _construirElementoLeyenda(Color bg, Color border, String etiqueta) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _construirEstadisticasAsientos() {
    final libres = widget.ruta.totalSeats -
        _asientosOcupados.values.where((v) => v).length;
    final seleccionados = _asientosSeleccionados.length;
    final ocupados = widget.ruta.totalSeats - libres;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _construirElementoEstadistica('$libres', 'Libres',
              widget.empresa.colorPrimary),
          _construirElementoEstadistica(
              '$ocupados', 'Ocupados', const Color(0xFFE74C3C)),
          _construirElementoEstadistica('$seleccionados', 'Selec.',
              widget.empresa.colorPrimary),
        ],
      ),
    );
  }

  Widget _construirElementoEstadistica(
      String valor, String etiqueta, Color color) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _construirTarjetaInfo(
    String valor,
    String etiqueta,
    IconData icono,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icono, color: widget.empresa.colorPrimary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirCampoTexto(
    TextEditingController controlador,
    String etiqueta,
    IconData icono,
    String sugerencia,
    String? Function() validador,
  ) {
    final error = validador();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controlador,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: sugerencia,
            hintStyle:
                const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            prefixIcon:
                Icon(icono, color: widget.empresa.colorPrimary, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : widget.empresa.colorPrimary,
                width: 2,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _irAlSiguientePaso() {
    if (_pasoActual == 2) {
      // Paso final: confirmar reserva
      _confirmarReserva();
    } else {
      _controladorPagina.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _pasoActual++);
    }
  }

  Future<void> _confirmarReserva() async {
    // Mostrar diálogo de carga
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Procesando tu reserva...',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.empresa.colorPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Obtener el provider de booking
      final bookingProvider = context.read<BookingProvider>();

      // Convertir índices de asientos a números 1-indexed
      final asientosReservados = _asientosSeleccionados
          .map((indice) => indice + 1)
          .toList();

      // Crear la reserva en el backend
      final fare = widget.ruta.price.toDouble();
      final totalPrice = asientosReservados.length * fare;
      final success = await bookingProvider.createBooking(
        routeId: (widget.ruta.id ?? 1).toString(),
        passengerName: _controladorNombre.text.trim(),
        passengerEmail: _controladorEmail.text.trim(),
        passengerPhone: _controladorTelefono.text.trim(),
        seatNumbers: asientosReservados,
        totalPrice: totalPrice,
      );

      if (!mounted) return;

      // Cerrar diálogo de carga
      Navigator.pop(context);

      if (success) {
        // Mostrar éxito y cerrar
        final booking = bookingProvider.currentBooking;
        if (booking != null) {
          _mostrarExito(booking.toJson());
        }
      } else {
        // Mostrar error
        _mostrarError(bookingProvider.errorMessage ??
            'Error desconocido al crear reserva');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _mostrarError(e.toString());
    }
  }

  void _mostrarExito(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Reserva Confirmada!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${booking['id']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu reserva ha sido guardada.\nVerifica tu email para los detalles.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo de éxito
                  Navigator.pop(context); // Cerrar go principal
                  widget.alConfirmar(_asientosSeleccionados.toList());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error en la Reserva',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _irAlPasoAnterior() {
    _controladorPagina.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _pasoActual--);
  }

  bool _puedeAvanzar() {
    if (_pasoActual == 0) return _esFormularioValido;
    if (_pasoActual == 1) return _asientosSeleccionados.isNotEmpty;
    return true;
  }
}
