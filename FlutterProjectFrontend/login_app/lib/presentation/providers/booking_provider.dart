import 'package:flutter/foundation.dart';
import 'package:login_app/data/repositories/booking_repository.dart';
import 'package:login_app/data/services/booking_service.dart';

export 'package:login_app/data/services/booking_service.dart' show BookingModel;

enum BookingState { initial, loading, success, error }

/// Provider para gestionar reservas con patrón consistente
class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;
  BookingState _state = BookingState.initial;
  BookingModel? _currentBooking;
  List<BookingModel> _userBookings = [];
  List<int> _availableSeats = [];
  String? _errorMessage;
  String? _successMessage;

  BookingState get state => _state;
  BookingModel? get currentBooking => _currentBooking;
  List<BookingModel> get userBookings => _userBookings;
  List<int> get availableSeats => _availableSeats;
  bool get isLoading => _state == BookingState.loading;
  bool get hasError => _state == BookingState.error;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  BookingProvider({BookingRepository? repository})
      : _repository = repository ?? BookingRepository(bookingService: BookingService());

  Future<bool> loadAvailableSeats(String routeId) async {
    try {
      _setState(BookingState.loading);
      _clearMessages();
      _availableSeats = await _repository.getAvailableSeats(routeId);
      _setState(BookingState.success);
      _successMessage = 'Asientos cargados correctamente';
      return true;
    } catch (e) {
      _handleError('Error al cargar asientos: ${e.toString()}');
      return false;
    }
  }

  Future<bool> createBooking({
    required String routeId,
    required String passengerName,
    required String passengerEmail,
    required String passengerPhone,
    required List<int> seatNumbers,
    required double totalPrice,
  }) async {
    try {
      _setState(BookingState.loading);
      _clearMessages();
      _currentBooking = await _repository.createBooking(
        routeId: routeId,
        passengerName: passengerName,
        passengerEmail: passengerEmail,
        passengerPhone: passengerPhone,
        seatNumbers: seatNumbers,
        totalPrice: totalPrice,
      );
      if (_currentBooking != null) {
        _setState(BookingState.success);
        _successMessage = 'Reserva creada exitosamente';
        await loadAvailableSeats(routeId);
        return true;
      } else {
        _handleError('No se pudo crear la reserva. Los asientos pueden estar ocupados.');
        return false;
      }
    } catch (e) {
      _handleError('Error al crear reserva: ${e.toString()}');
      return false;
    }
  }

  Future<bool> loadUserBookings(String email) async {
    try {
      _setState(BookingState.loading);
      _clearMessages();
      _userBookings = await _repository.getBookingsByEmail(email);
      _setState(BookingState.success);
      _successMessage = 'Reservas cargadas correctamente';
      return true;
    } catch (e) {
      _handleError('Error al cargar reservas: ${e.toString()}');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      _setState(BookingState.loading);
      _clearMessages();
      final success = await _repository.cancelBooking(bookingId);
      if (success) {
        _setState(BookingState.success);
        _successMessage = 'Reserva cancelada exitosamente';
        final idx = _userBookings.indexWhere((b) => b.id == bookingId);
        if (idx != -1) {
          _userBookings[idx] = _userBookings[idx].copyWith(status: 'cancelled');
        }
        return true;
      } else {
        _handleError('No se pudo cancelar la reserva');
        return false;
      }
    } catch (e) {
      _handleError('Error al cancelar reserva: ${e.toString()}');
      return false;
    }
  }

  void clearState() {
    _currentBooking = null;
    _errorMessage = null;
    _availableSeats = [];
    _successMessage = null;
    _setState(BookingState.initial);
  }

  void _setState(BookingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _handleError(String message) {
    _errorMessage = message;
    _setState(BookingState.error);
  }
}


