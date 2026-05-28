# 🚀 Sistema de Reservas de Transporte - Proyecto PGC

**Estado**: ✅ Completado y Funcional  
**Fecha**: 24 de mayo de 2026  
**Tecnologías**: Django REST Framework + Flutter + SQLite  

---

## 📋 Descripción General

Sistema completo de reserva de asientos para transporte interdepartamental. Permite que los pasajeros busquen rutas, seleccionen asientos, realicen pagos y reciban confirmación inmediata. Los administradores pueden gestionar rutas, conductores, buses y visualizar todas las reservas en tiempo real.

### ✨ Características Principales

- 🎫 **Reserva de Asientos**: Selección interactiva de asientos con validación en tiempo real
- 💾 **Persistencia de Datos**: Todas las reservas se guardan en base de datos
- 🔍 **Validación Automática**: Previene overbooking y asientos duplicados
- 👤 **Perfil de Visitante**: Los pasajeros pueden buscar rutas y hacer reservas
- 👨‍💼 **Perfil de Administrador**: Gestión completa del sistema
- ✅ **Confirmación Inmediata**: Respuesta en tiempo real después de la reserva

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────┐
│     FLUTTER APP (Frontend)          │
│  ├─ Visitante (Búsqueda y Reservas) │
│  └─ Admin (Gestión del Sistema)     │
└──────────────┬──────────────────────┘
               │ HTTP API
               ↓
┌─────────────────────────────────────┐
│   DJANGO REST API (Backend)         │
│  ├─ Routes Endpoints                │
│  ├─ Bookings Endpoints              │
│  ├─ Passengers Endpoints            │
│  └─ Admin Panel                     │
└──────────────┬──────────────────────┘
               │ ORM
               ↓
┌─────────────────────────────────────┐
│     SQLite Database                 │
│  ├─ routes                          │
│  ├─ passengers                      │
│  ├─ bookings                        │
│  ├─ seatreservations                │
│  ├─ buses                           │
│  ├─ drivers                         │
│  └─ schedules                       │
└─────────────────────────────────────┘
```

---

## 📁 Estructura del Proyecto

```
Proyecto_PGC/
├── backend/
│   ├── manage.py                 # Ejecutable principal de Django
│   ├── db.sqlite3               # Base de datos
│   ├── populate_data.py         # Script para llenar BD con datos de ejemplo
│   ├── run_server.ps1           # Script para iniciar servidor (Windows)
│   ├── backend/
│   │   ├── settings.py          # Configuración de Django
│   │   ├── urls.py              # URLs principales
│   │   └── wsgi.py
│   └── routes/
│       ├── models.py            # Modelos: Route, Passenger, Booking, etc.
│       ├── serializers.py       # Validación y serialización de datos
│       ├── views.py             # ViewSets y endpoints REST
│       ├── urls.py              # URLs de rutas
│       ├── admin.py             # Interfaz de administración
│       └── migrations/          # Migraciones de BD
│
└── FlutterProjectFrontend/
    └── login_app/
        ├── lib/
        │   ├── main.dart        # Punto de entrada
        │   ├── core/
        │   │   ├── utils/validators.dart  # Validadores
        │   │   ├── constants/             # Constantes de la app
        │   │   ├── exceptions/            # Excepciones personalizadas
        │   │   └── theme/                 # Tema de la app
        │   ├── data/
        │   │   ├── models/               # Modelos de datos (RouteModel, etc.)
        │   │   ├── repositories/         # Capa de acceso a datos
        │   │   └── services/             # Servicios HTTP
        │   └── presentation/
        │       ├── providers/            # State management (Provider)
        │       ├── screens/              # Pantallas de la app
        │       │   ├── auth/             # Login
        │       │   ├── visitor/          # Pantallas del pasajero
        │       │   └── admin/            # Panel de administración
        │       └── widgets/              # Componentes reutilizables
        └── pubspec.yaml         # Dependencias

```

---

## 🚀 Inicio Rápido

### Requisitos Previos

- **Backend**: Python 3.8+, Django 4.0+
- **Frontend**: Flutter 3.0+, Dart 3.0+
- **Base de Datos**: SQLite (incluida)

### Paso 1: Iniciar el Backend

```bash
cd backend

# Instalar dependencias
pip install -r requirements.txt

# Aplicar migraciones
python manage.py migrate

# Llenar BD con datos de ejemplo
python manage.py shell < populate_data.py

# Iniciar servidor
python manage.py runserver
# Servidor disponible en: http://127.0.0.1:8000
```

### Paso 2: Iniciar la Aplicación Flutter

```bash
cd FlutterProjectFrontend/login_app

# Obtener dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run
```

### Paso 3: Acceder a la Aplicación

1. **Aplicación Flutter**: Se abre automáticamente en dispositivo/emulador
2. **Panel Django Admin**: http://127.0.0.1:8000/admin
   - Usuario: `admin`
   - Contraseña: `admin123`

---

## 📊 Endpoints de la API

### Rutas
```
GET    /api/routes/                     - Listar todas las rutas
GET    /api/routes/{id}/                - Obtener ruta específica
GET    /api/routes/{id}/available_seats/ - Asientos disponibles
POST   /api/routes/                     - Crear ruta (Admin)
PUT    /api/routes/{id}/                - Actualizar ruta (Admin)
DELETE /api/routes/{id}/                - Eliminar ruta (Admin)
```

### Reservas
```
POST   /api/bookings/                   - Crear nueva reserva
GET    /api/bookings/                   - Listar reservas (Admin)
GET    /api/bookings/{id}/              - Obtener reserva específica
POST   /api/bookings/{id}/confirm/      - Confirmar reserva
POST   /api/bookings/{id}/cancel/       - Cancelar reserva
GET    /api/bookings/by_passenger_email/ - Historial de pasajero
```

### Pasajeros
```
GET    /api/passengers/                 - Listar pasajeros (Admin)
POST   /api/passengers/                 - Crear pasajero
GET    /api/passengers/{id}/            - Obtener pasajero
```

---

## 🎯 Flujo de Uso: Hacer una Reserva

### 1. Buscar Rutas
- Usuario abre la app y ve lista de rutas disponibles
- Cada ruta muestra: nombre, horario, precio y asientos disponibles
- Ejemplo: "Girardot - Cali | 2:30 PM | $28,000 | 10 de 14 disponibles"

### 2. Seleccionar Ruta
- Usuario toca una ruta para ver más detalles
- Se abre diálogo con 3 pasos del proceso

### 3. Paso 1: Datos Personales
- **Nombre**: Solo letras y espacios (mín. 3 caracteres)
- **Teléfono**: Solo números (mín. 10 dígitos)
- **Correo**: Formato válido de email
- ✅ Validación en tiempo real con mensajes de error

### 4. Paso 2: Seleccionar Asientos
- Visualización interactiva del bus (14 asientos)
- Asientos disponibles: color primario (tocables)
- Asientos ocupados: gris (no tocables)
- Asientos seleccionados: color primario oscuro
- Estadísticas en tiempo real: libres, ocupados, seleccionados

### 5. Paso 3: Confirmar Reserva
- Resumen de datos ingresados
- Número de asientos y precio total
- Botón "Confirmar" para finalizar

### 6. Confirmación
- ✅ Éxito: "Reserva #123 confirmada. Verifica tu email."
- ❌ Error: Mensaje detallado del problema
- Reserva guardada en base de datos inmediatamente

---

## 🔐 Validaciones Implementadas

### Datos del Pasajero
- ✅ Nombre obligatorio, mín. 3 caracteres, solo letras
- ✅ Teléfono obligatorio, solo números, mín. 10 dígitos
- ✅ Correo obligatorio, formato válido

### Asientos
- ✅ Asiento dentro del rango válido (1 a 14)
- ✅ No seleccionar duplicados
- ✅ Asiento debe estar disponible (no reservado)
- ✅ No se puede reservar más asientos de los disponibles

### Base de Datos
- ✅ ForeignKey constraints previenen datos huérfanos
- ✅ Unique constraints evitan duplicados
- ✅ Capacidad disponible se decrementa correctamente

---

## 💾 Base de Datos

### Tabla: routes
```
id           | Integer | PK
route_name   | String  | "Girardot - Cali"
route_number | String  | "GIR-003"
start_point  | String  | "Terminal Girardot"
end_point    | String  | "Terminal Cali"
fare         | Integer | 28000
total_seats  | Integer | 14
available_seats | Integer | 10
driver_name  | String  | "José Martínez"
vehicle_plate | String  | "GRE-9999"
schedule     | Time    | 14:30
created_at   | DateTime|
```

### Tabla: passengers
```
id        | Integer | PK
full_name | String  | "Juan Pérez García"
email     | String  | "juan@email.com"
phone     | String  | "3001234567"
```

### Tabla: bookings
```
id            | Integer | PK
route_id      | FK      | → routes.id
passenger_id  | FK      | → passengers.id
num_seats     | Integer | 2
total_price   | Integer | 56000
status        | String  | "CONFIRMED"
created_at    | DateTime|
confirmed_at  | DateTime|
```

### Tabla: seatreservations
```
id           | Integer | PK
booking_id   | FK      | → bookings.id
seat_number  | Integer | 1
reserved_at  | DateTime|
```

---

## 🔧 Configuración

### Backend

**Archivo**: `backend/backend/settings.py`

```python
# Base de datos
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# CORS para Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
    "http://192.168.1.100:8000",  # Cambiar IP según tu red
]
```

### Frontend

**Archivo**: `lib/data/repositories/booking_repository.dart`

```dart
// Cambiar URL según donde esté tu servidor
const String baseUrl = 'http://192.168.1.100:8000';
```

---

## 📱 Pantallas de la Aplicación

### Visitante
- **Pantalla Principal**: Lista de rutas disponibles
- **Pantalla de Búsqueda**: Filtrar rutas
- **Diálogo de Reserva**: 3 pasos para agendar
- **Pantalla de Confirmación**: Resumen de reserva

### Administrador
- **Dashboard**: Estadísticas generales
- **Gestión de Rutas**: CRUD de rutas
- **Gestión de Buses**: Listado de vehículos
- **Gestión de Conductores**: Información de conductores
- **Gestión de Horarios**: Horarios de viajes
- **Reservas**: Historial completo de reservas

---

## 🧪 Datos de Ejemplo

El proyecto incluye 3 rutas de prueba precargadas:

| Ruta | Destino | Hora | Precio | Asientos |
|------|---------|------|--------|----------|
| GIR-001 | Girardot - Medellín | 10:00 AM | $35,000 | 14/14 |
| GIR-002 | Girardot - Bogotá | 6:00 AM | $45,000 | 14/14 |
| GIR-003 | Girardot - Cali | 2:30 PM | $28,000 | 10/14 |

Para llenar la BD:
```bash
cd backend
python manage.py shell < populate_data.py
```

---

## 🐛 Solución de Problemas

### La app no se conecta al servidor
- Verificar que Django está corriendo: `python manage.py runserver`
- Cambiar la URL en `booking_repository.dart` a la IP correcta
- Asegurar que el firewall no bloquea puerto 8000

### Error: "Asiento ya reservado"
- El asiento fue reservado por otro usuario recientemente
- Recargar la app para obtener lista actualizada de asientos

### Errores de validación
- **Nombre**: Mín. 3 caracteres, solo letras
- **Teléfono**: Mín. 10 dígitos, solo números
- **Correo**: Formato válido (ej: usuario@dominio.com)

### Base de datos corrupta
- Eliminar `backend/db.sqlite3`
- Ejecutar: `python manage.py migrate`
- Rellenar datos: `python manage.py shell < populate_data.py`

---

## 📈 Mejoras Futuras Recomendadas

1. **Pago Integrado**: Stripe, PayPal o PSE
2. **Notificaciones**: Email/SMS de confirmación
3. **Autenticación**: Login con registro de usuarios
4. **Historial de Reservas**: Ver reservas pasadas en la app
5. **Cancelación con Reembolso**: Permitir anular reservas
6. **Actualizaciones en Tiempo Real**: WebSocket para asientos
7. **Reportes**: Panel de ocupación y estadísticas
8. **Multi-idioma**: Soporte para inglés y otros idiomas

---

## 📚 Archivos Clave

### Backend
- `backend/routes/models.py` - Estructura de datos
- `backend/routes/serializers.py` - Validación de datos
- `backend/routes/views.py` - Endpoints REST
- `backend/populate_data.py` - Datos de ejemplo

### Frontend
- `lib/main.dart` - Punto de entrada
- `lib/data/repositories/booking_repository.dart` - API HTTP
- `lib/presentation/providers/booking_provider.dart` - State management
- `lib/presentation/screens/visitor/dialogo_flujo_reserva.dart` - Formulario de reserva

---

## 🎓 Conceptos Implementados

- ✅ **REST API**: Comunicación HTTP entre cliente y servidor
- ✅ **State Management**: Provider pattern en Flutter
- ✅ **ORM**: Django ORM con relaciones
- ✅ **Validación**: Serializers en Django y formularios en Flutter
- ✅ **Transacciones**: Integridad de datos
- ✅ **Diseño de BD**: Modelos normalizados
- ✅ **Arquitectura Limpia**: Separación de capas (Data, Domain, Presentation)

---

## 👥 Contribuciones

Este proyecto fue desarrollado como parte de un ejercicio de aprendizaje en tecnologías web modernas.

---

## 📄 Licencia

Este proyecto está disponible bajo licencia de uso educativo.

---

## 📞 Soporte

Para reportar bugs o sugerencias, contactar al equipo de desarrollo.

**Última actualización**: 26 de mayo de 2026
