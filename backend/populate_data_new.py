from routes.models import Route, CustomUser

# Crear rutas de ejemplo
routes_data = [
    {
        'route_name': 'Girardot - Medellín',
        'route_number': 'GIR-001',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Medellín',
        'fare': 35000,
        'estimated_duration': 480,
        'description': 'Ruta directa con paradas en Fusagasugá',
        'is_active': True,
    },
    {
        'route_name': 'Girardot - Bogotá',
        'route_number': 'GIR-002',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Bogotá',
        'fare': 45000,
        'estimated_duration': 300,
        'description': 'Ruta express directa',
        'is_active': True,
    },
    {
        'route_name': 'Girardot - Cali',
        'route_number': 'GIR-003',
        'start_point': 'Terminal Girardot',
        'end_point': 'Terminal Cali',
        'fare': 28000,
        'estimated_duration': 240,
        'description': 'Ruta con paradas intermedias',
        'is_active': True,
    },
]

print("Creando rutas...")
for route_data in routes_data:
    route, created = Route.objects.get_or_create(**route_data)
    if created:
        print(f"✓ Ruta creada: {route.route_name}")
    else:
        print(f"✓ Ruta ya existe: {route.route_name}")

# Crear usuarios de ejemplo (visitantes)
users_data = [
    {
        'username': 'juan_perez',
        'email': 'juan@example.com',
        'first_name': 'Juan',
        'last_name': 'Pérez',
        'phone': '3001234567',
        'password': 'testpass123',
        'role': 'visitor',
    },
    {
        'username': 'maria_gomez',
        'email': 'maria@example.com',
        'first_name': 'María',
        'last_name': 'Gómez',
        'phone': '3009876543',
        'password': 'testpass123',
        'role': 'visitor',
    },
]

print("\nCreando usuarios visitantes...")
for user_data in users_data:
    password = user_data.pop('password')
    try:
        user, created = CustomUser.objects.get_or_create(
            username=user_data['username'],
            defaults=user_data
        )
        if created:
            user.set_password(password)
            user.save()
            print(f"✓ Usuario creado: {user.username}")
        else:
            print(f"✓ Usuario ya existe: {user.username}")
    except Exception as e:
        print(f"✗ Error creando usuario: {e}")

print("\n✅ Datos de ejemplo cargados correctamente")
