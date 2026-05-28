import 'package:login_app/data/services/booking_service.dart';

/// Repositorio de Reservas
/// Maneja toda la lógica de negocio relacionada con reservas
class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  /// Obtiene los asientos disponibles para una ruta
  Future<List<int>> getAvailableSeats(String routeId) async {
    return await _bookingService.getAvailableSeats(routeId);
  }

  /// Crea una nueva reserva
  Future<BookingModel?> createBooking({
    required String routeId,
    required String passengerName,
    required String passengerEmail,
    required String passengerPhone,
    required List<int> seatNumbers,
    required double totalPrice,
  }) async {
    return await _bookingService.createBooking(
      routeId: routeId,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passengerPhone: passengerPhone,
      seatNumbers: seatNumbers,
      totalPrice: totalPrice,
    );
  }

  /// Obtiene las reservas de un pasajero por email
  Future<List<BookingModel>> getBookingsByEmail(String email) async {
    return await _bookingService.getBookingsByEmail(email);
  }

  /// Obtiene las reservas de una ruta específica
  Future<List<BookingModel>> getBookingsByRoute(String routeId) async {
    return await _bookingService.getBookingsByRoute(routeId);
  }

  /// Cancela una reserva existente
  Future<bool> cancelBooking(String bookingId) async {
    return await _bookingService.cancelBooking(bookingId);
  }

  /// Obtiene una reserva por ID
  Future<BookingModel?> getBookingById(String id) async {
    return await _bookingService.getBookingById(id);
  }

  /// Obtiene todas las reservas
  Future<List<BookingModel>> getAllBookings() async {
    return await _bookingService.getAllBookings();
  }
}

