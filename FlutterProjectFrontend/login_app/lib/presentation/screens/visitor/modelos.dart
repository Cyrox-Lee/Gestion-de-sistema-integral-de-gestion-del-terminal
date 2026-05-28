import 'package:flutter/material.dart';

class TransportCompany {
  final String id;
  final String name;
  final String description;
  final Color colorPrimary;
  final Color colorSecondary;
  final IconData icon;
  final List<TransportRoute> routes;

  TransportCompany({
    required this.id,
    required this.name,
    required this.description,
    required this.colorPrimary,
    required this.colorSecondary,
    required this.icon,
    required this.routes,
  });
}

class TransportRoute {
  final int? id;  // ID de la ruta en el backend (opcional para compatibilidad)
  final String name;
  final String origin;
  final String destination;
  final String schedule;
  final String estimatedTime;
  final String driverName;
  final String vehiclePlate;
  final int availableSeats;
  final int totalSeats;
  final int price;

  TransportRoute({
    this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.schedule,
    required this.estimatedTime,
    required this.driverName,
    required this.vehiclePlate,
    required this.availableSeats,
    required this.totalSeats,
    required this.price,
  });
}
