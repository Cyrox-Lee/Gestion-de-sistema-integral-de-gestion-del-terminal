#!/usr/bin/env python
"""
Script para actualizar todas las rutas a Macarena
"""
import os
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from routes.models import Route

# Actualizar todas las rutas a Macarena
macarena_routes = [
    {
        'route_name': 'Macarena',
        'route_number': 'M-1',
        'start_point': 'Terminal Macarena',
        'end_point': 'Centro Comercial',
        'fare': 2500,
        'estimated_duration': 30,
        'description': 'Ruta principal Macarena',
    },
    {
        'route_name': 'Macarena Express',
        'route_number': 'M-2',
        'start_point': 'Terminal Macarena',
        'end_point': 'Parque Central',
        'fare': 3000,
        'estimated_duration': 45,
        'description': 'Ruta express Macarena',
    },
    {
        'route_name': 'Macarena Local',
        'route_number': 'M-3',
        'start_point': 'Terminal Macarena',
        'end_point': 'Zona Residencial',
        'fare': 2000,
        'estimated_duration': 25,
        'description': 'Ruta local Macarena',
    },
]

# Eliminar todas las rutas existentes
Route.objects.all().delete()
print(f"✓ Se eliminaron todas las rutas existentes")

# Crear las nuevas rutas de Macarena
for route_data in macarena_routes:
    route = Route.objects.create(**route_data)
    print(f"✓ Creada ruta: {route.route_name} ({route.route_number})")

# Mostrar todas las rutas actualizadas
print("\n--- RUTAS ACTUALIZADAS ---")
for route in Route.objects.all():
    print(f"ID: {route.id} | Nombre: {route.route_name} | Número: {route.route_number}")
    print(f"   Origen: {route.start_point} → Destino: {route.end_point}")
    print(f"   Tarifa: ${route.fare} | Duración: {route.estimated_duration} min")
    print(f"   Activa: {route.is_active}\n")

print("✓ Actualización completada exitosamente")
