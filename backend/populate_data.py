"""
Script para popular la BD con datos de ejemplo
Uso: python manage.py shell < populate_data.py
"""
from routes.models import Route, Passenger, Booking, SeatReservation
from datetime import time, datetime, timedelta
from django.utils import timezone

# Limpiar datos existentes
Route.objects.all().delete()
Passenger.objects.all().delete()

# Crear rutas de ejemplo
routes_data = [
    {
        'route_name': 'Girardot - Medellín',
        'route_number': 'GIR-001',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Medellín',
        'fare': 35000,
        'estimated_duration': 150,
        'description': 'Ruta expresa Girardot-Medellín',
        'total_seats': 14,
        'available_seats': 14,
        'driver_name': 'Miguel Hernández',
        'vehicle_plate': 'GRD-5678',
        'schedule': time(10, 0),
    },
    {
        'route_name': 'Girardot - Bogotá',
        'route_number': 'GIR-002',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Bogotá',
        'fare': 45000,
        'estimated_duration': 240,
        'description': 'Ruta directa Girardot-Bogotá',
        'total_seats': 14,
        'available_seats': 14,
        'driver_name': 'Carlos Rodríguez',
        'vehicle_plate': 'GRT-1234',
        'schedule': time(6, 0),
    },
    {
        'route_name': 'Girardot - Cali',
        'route_number': 'GIR-003',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Cali',
        'fare': 28000,
        'estimated_duration': 120,
        'description': 'Ruta frecuente Girardot-Cali',
        'total_seats': 14,
        'available_seats': 10,  # 4 asientos ya reservados
        'driver_name': 'José Martínez',
        'vehicle_plate': 'GRE-9999',
        'schedule': time(14, 30),
    },
]

routes = []
for data in routes_data:
    route = Route.objects.create(**data)
    routes.append(route)
    print(f"✓ Ruta creada: {route.route_name}")

# Crear pasajeros de ejemplo
passengers_data = [
    {
        'full_name': 'Juan Pérez García',
        'email': 'juan.perez@email.com',
        'phone': '3001234567',
    },
    {
        'full_name': 'María López Rodriguez',
        'email': 'maria.lopez@email.com',
        'phone': '3157654321',
    },
    {
        'full_name': 'Carlos Sánchez Martínez',
        'email': 'carlos.sanchez@email.com',
        'phone': '3209876543',
    },
]

passengers = []
for data in passengers_data:
    passenger = Passenger.objects.create(**data)
    passengers.append(passenger)
    print(f"✓ Pasajero creado: {passenger.full_name}")

# Crear reservas de ejemplo
booking1 = Booking.objects.create(
    route=routes[2],  # Ruta Cali
    passenger=passengers[0],
    num_seats=2,
    total_price=28000 * 2,
    status='CONFIRMED',
    confirmed_at=timezone.now()
)

# Crear reservas de asientos
SeatReservation.objects.create(booking=booking1, seat_number=1)
SeatReservation.objects.create(booking=booking1, seat_number=2)
print(f"✓ Reserva creada: {booking1.id} - Asientos 1,2")

booking2 = Booking.objects.create(
    route=routes[2],  # Ruta Cali
    passenger=passengers[1],
    num_seats=2,
    total_price=28000 * 2,
    status='CONFIRMED',
    confirmed_at=timezone.now()
)

SeatReservation.objects.create(booking=booking2, seat_number=3)
SeatReservation.objects.create(booking=booking2, seat_number=4)
print(f"✓ Reserva creada: {booking2.id} - Asientos 3,4")

print("\n" + "="*50)
print("📊 Datos de población completados exitosamente")
print("="*50)
