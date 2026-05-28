import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:login_app/data/services/token_storage.dart';

/// Modelo para representar una reserva
class BookingModel {
  final String id;
  final String routeId;
  final String passengerName;
  final String passengerEmail;
  final String passengerPhone;
  final List<int> seatNumbers;
  final double totalPrice;
  final DateTime bookingDate;
  final String status; // 'confirmed', 'pending', 'cancelled'

  BookingModel({
    required this.id,
    required this.routeId,
    required this.passengerName,
    required this.passengerEmail,
    required this.passengerPhone,
    required this.seatNumbers,
    required this.totalPrice,
    required this.bookingDate,
    this.status = 'confirmed',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final seatsJson = json['seats'] as List<dynamic>?;
    final seatNumbers = seatsJson != null
        ? seatsJson.map((seat) => seat['seat_number'] as int).toList()
        : <int>[];

    final routeId = json['route']?.toString() ?? json['route_detail']?['id']?.toString() ?? '';
    final userDetail = json['user_detail'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'].toString(),
      routeId: routeId,
      passengerName: userDetail?['username'] ?? '',
      passengerEmail: userDetail?['email'] ?? '',
      passengerPhone: userDetail?['phone'] ?? '',
      seatNumbers: seatNumbers,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      bookingDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      status: json['status'] ?? 'confirmed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'passenger_name': passengerName,
      'passenger_email': passengerEmail,
      'passenger_phone': passengerPhone,
      'seat_numbers': seatNumbers,
      'total_price': totalPrice,
      'booking_date': bookingDate.toIso8601String(),
      'status': status,
    };
  }

  BookingModel copyWith({
    String? id,
    String? routeId,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    List<int>? seatNumbers,
    double? totalPrice,
    DateTime? bookingDate,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      passengerName: passengerName ?? this.passengerName,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      seatNumbers: seatNumbers ?? this.seatNumbers,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
    );
  }
}

/// Servicio de reservas que usa el backend Django.
class BookingService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const int seatsPerBus = 40;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<BookingModel?> createBooking({
    required String routeId,
    required String passengerName,
    required String passengerEmail,
    required String passengerPhone,
    required List<int> seatNumbers,
    required double totalPrice,
  }) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/'),
      headers: headers,
      body: jsonEncode({
        'route': int.tryParse(routeId) ?? routeId,
        'num_seats': seatNumbers.length,
        'total_price': totalPrice.round(),
        'seat_numbers': seatNumbers,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<List<int>> getAvailableSeats(String routeId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/reserved_seats/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener asientos reservados: ${response.statusCode}');
    }

    final reserved = List<int>.from(jsonDecode(response.body) as List<dynamic>);
    return List<int>.generate(seatsPerBus, (i) => i + 1)
        .where((seat) => !reserved.contains(seat))
        .toList();
  }

  Future<List<BookingModel>> getBookingsByEmail(String email) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener reservas: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body);
    final bookings = jsonData is List ? jsonData : jsonData['results'] ?? [];
    return (bookings as List<dynamic>)
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingModel>> getBookingsByRoute(String routeId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/?route=$routeId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener reservas por ruta: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body);
    final bookings = jsonData is List ? jsonData : jsonData['results'] ?? [];
    return (bookings as List<dynamic>)
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> cancelBooking(String bookingId) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/cancel/'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  Future<BookingModel?> getBookingById(String id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$id/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<BookingModel>> getAllBookings() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener reservas: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body);
    final bookings = jsonData is List ? jsonData : jsonData['results'] ?? [];
    return (bookings as List<dynamic>)
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
