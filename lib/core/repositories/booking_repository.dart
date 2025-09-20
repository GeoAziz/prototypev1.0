import 'dart:async';
import '../models/booking.dart';
import '../services/db_helper.dart';

class BookingRepository {
  final _controller = StreamController<List<Booking>>.broadcast();
  final DBHelper _dbHelper = DBHelper.instance;

  Stream<List<Booking>> get bookingsStream => _controller.stream;

  Future<void> addBooking(Booking booking) async {
    await _dbHelper.insertBooking(booking);
    _updateStream();
  }

  Future<void> updateBooking(Booking booking) async {
    await _dbHelper.updateBooking(booking);
    _updateStream();
  }

  Future<void> deleteBooking(String id) async {
    await _dbHelper.deleteBooking(id);
    _updateStream();
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    return _dbHelper.getBookingsByUserId(userId);
  }

  Future<void> _updateStream() async {
    final bookings = await _dbHelper.getBookings();
    _controller.add(bookings);
  }

  void dispose() {
    _controller.close();
  }
}
