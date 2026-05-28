#!/usr/bin/env python3
"""
Script para probar la API de Django - Rutas
Verifica que se pueden crear, leer, actualizar y eliminar rutas
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:8000"
API_ENDPOINT = f"{BASE_URL}/api/routes/"

def test_get_routes():
    """Obtener todas las rutas"""
    print("\n📍 TEST 1: Obtener todas las rutas")
    print(f"GET {API_ENDPOINT}")
    
    try:
        response = requests.get(API_ENDPOINT)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            routes = response.json()
            if isinstance(routes, dict) and 'results' in routes:
                routes = routes['results']
            
            print(f"✅ Se encontraron {len(routes)} ruta(s)")
            for route in routes:
                print(f"  - {route.get('route_name')} ({route.get('id')})")
            return routes
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_create_route():
    """Crear una nueva ruta"""
    print("\n📍 TEST 2: Crear una nueva ruta")
    print(f"POST {API_ENDPOINT}")
    
    new_route = {
        "route_name": "Ruta Test Python",
        "route_number": "TEST-001",
        "start_point": "Punto A",
        "end_point": "Punto B",
        "fare": 2500,
        "estimated_duration": 45,
        "description": "Ruta creada desde script de prueba",
        "is_active": True
    }
    
    print(f"Datos: {json.dumps(new_route, indent=2)}")
    
    try:
        response = requests.post(API_ENDPOINT, json=new_route)
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            created_route = response.json()
            print(f"✅ Ruta creada exitosamente")
            print(f"  ID: {created_route.get('id')}")
            print(f"  Nombre: {created_route.get('route_name')}")
            return created_route
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_update_route(route_id):
    """Actualizar una ruta"""
    print(f"\n📍 TEST 3: Actualizar ruta (ID: {route_id})")
    update_url = f"{API_ENDPOINT}{route_id}/"
    print(f"PUT {update_url}")
    
    updated_data = {
        "route_name": "Ruta Test Python ACTUALIZADA",
        "route_number": "TEST-001",
        "start_point": "Punto A Actualizado",
        "end_point": "Punto B Actualizado",
        "fare": 3000,
        "estimated_duration": 50,
        "description": "Ruta actualizada desde script",
        "is_active": True
    }
    
    print(f"Datos: {json.dumps(updated_data, indent=2)}")
    
    try:
        response = requests.put(update_url, json=updated_data)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            updated_route = response.json()
            print(f"✅ Ruta actualizada exitosamente")
            print(f"  Nombre: {updated_route.get('route_name')}")
            return True
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_route(route_id):
    """Obtener una ruta específica"""
    print(f"\n📍 TEST 4: Obtener ruta específica (ID: {route_id})")
    get_url = f"{API_ENDPOINT}{route_id}/"
    print(f"GET {get_url}")
    
    try:
        response = requests.get(get_url)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            route = response.json()
            print(f"✅ Ruta obtenida exitosamente")
            print(f"  Nombre: {route.get('route_name')}")
            print(f"  Número: {route.get('route_number')}")
            print(f"  Tarifa: ${route.get('fare')}")
            return route
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_delete_route(route_id):
    """Eliminar una ruta"""
    print(f"\n📍 TEST 5: Eliminar ruta (ID: {route_id})")
    delete_url = f"{API_ENDPOINT}{route_id}/"
    print(f"DELETE {delete_url}")
    
    try:
        response = requests.delete(delete_url)
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 204]:
            print(f"✅ Ruta eliminada exitosamente")
            return True
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def main():
    print("=" * 60)
    print("🧪 PRUEBAS DE API - RUTAS (Django)")
    print("=" * 60)
    print(f"Base URL: {BASE_URL}")
    
    # Test 1: Obtener rutas existentes
    existing_routes = test_get_routes()
    
    # Test 2: Crear una nueva ruta
    created_route = test_create_route()
    
    if created_route:
        route_id = created_route.get('id')
        
        # Test 3: Obtener la ruta creada
        test_get_route(route_id)
        
        # Test 4: Actualizar la ruta
        test_update_route(route_id)
        
        # Test 5: Obtener la ruta actualizada
        test_get_route(route_id)
        
        # Test 6: Eliminar la ruta
        test_delete_route(route_id)
        
        # Test 7: Verificar que se eliminó
        print(f"\n📍 TEST 6: Verificar eliminación")
        deleted_route = test_get_route(route_id)
        if deleted_route is None:
            print("✅ Ruta eliminada correctamente")
    
    # Mostrar rutas finales
    final_routes = test_get_routes()
    
    print("\n" + "=" * 60)
    print("✅ PRUEBAS COMPLETADAS")
    print("=" * 60)

if __name__ == "__main__":
    main()
