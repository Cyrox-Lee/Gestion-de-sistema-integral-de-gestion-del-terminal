class ScheduleModel {
  final String id;
  final int routeId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String status;
  final int seatsAvailable;
  final int totalSeats;
  final String? busNumber;

  ScheduleModel({
    required this.id,
    required this.routeId,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.seatsAvailable,
    required this.totalSeats,
    this.busNumber,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      routeId: json['route_id'] as int,
      departureTime: DateTime.parse(json['departure_time'] as String),
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
      status: json['status'] as String,
      seatsAvailable: json['seats_available'] as int,
      totalSeats: json['total_seats'] as int,
      busNumber: json['bus_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'status': status,
      'seats_available': seatsAvailable,
      'total_seats': totalSeats,
      'bus_number': busNumber,
    };
  }
}
