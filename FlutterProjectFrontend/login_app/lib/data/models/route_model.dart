class RouteModel {
  final String id;
  final String routeName;
  final String routeNumber;
  final String startPoint;
  final String endPoint;
  final double fare;
  final int estimatedDuration; // in minutes
  final String? description;
  final DateTime createdAt;
  final bool isActive;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.routeNumber,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
    required this.estimatedDuration,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
  return RouteModel(
    id: json['id'].toString(),
    routeName: json['route_name'] ?? '',
    routeNumber: json['route_number'] ?? '',
    startPoint: json['start_point'] ?? '',
    endPoint: json['end_point'] ?? '',
    fare: (json['fare'] ?? 0).toDouble(),
    estimatedDuration: json['estimated_duration'] ?? 0,
    description: json['description'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    isActive: json['is_active'] ?? true,
  );
}

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'route_name': routeName,
    'route_number': routeNumber,
    'start_point': startPoint,
    'end_point': endPoint,
    'fare': fare,
    'estimated_duration': estimatedDuration,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'is_active': isActive,
  };
}

  /// Convierte el modelo a JSON para creación (sin id ni created_at)
  /// Django genera estos campos automáticamente
  Map<String, dynamic> toCreateJson() {
  return {
    'route_name': routeName,
    'route_number': routeNumber,
    'start_point': startPoint,
    'end_point': endPoint,
    'fare': fare.toInt(),
    'estimated_duration': estimatedDuration,
    'description': description ?? '',
    'is_active': isActive,
  };
}

  /// Convierte el modelo a JSON para actualización
  /// Incluye todos los campos incluyendo id
  Map<String, dynamic> toUpdateJson() {
  return {
    'route_name': routeName,
    'route_number': routeNumber,
    'start_point': startPoint,
    'end_point': endPoint,
    'fare': fare.toInt(),
    'estimated_duration': estimatedDuration,
    'description': description ?? '',
    'is_active': isActive,
  };
}

  RouteModel copyWith({
    String? id,
    String? routeName,
    String? routeNumber,
    String? startPoint,
    String? endPoint,
    double? fare,
    int? estimatedDuration,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RouteModel(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      fare: fare ?? this.fare,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
