#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from routes.models import Route

print("Actualizando todas las rutas a Macarena...")
print("=" * 60)

# Actualizar todas las rutas a Macarena
updated = Route.objects.all().update(
    start_point='Terminal Macarena',
)

print(f"\n✅ {updated} ruta(s) actualizadas")
print("\nRutas después de la actualización:")
print("-" * 60)

for ruta in Route.objects.all():
    print(f"ID: {ruta.id}")
    print(f"  Nombre: {ruta.route_name}")
    print(f"  Origen: {ruta.start_point}")
    print(f"  Destino: {ruta.end_point}")
    print(f"  Precio: ${ruta.fare}")
    print()
