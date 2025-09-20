import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  BookingState({this.bookings = const [], this.isLoading = false, this.error});

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository repo;

  BookingNotifier(this.repo) : super(BookingState());

  Future<void> fetchBookingsForUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final bookings = await repo.fetchBookingsForUser(userId);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch bookings: $e',
      );
    }
  }

  Future<void> createBooking(Booking booking) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.createBooking(booking);
      state = state.copyWith(
        bookings: [...state.bookings, booking],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create booking: $e',
      );
    }
  }

  Future<void> updateBooking(Booking booking) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.updateBooking(booking);
      state = state.copyWith(
        bookings: state.bookings
            .map((b) => b.id == booking.id ? booking : b)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update booking: $e',
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await repo.cancelBooking(bookingId);
      state = state.copyWith(
        bookings: state.bookings.where((b) => b.id != bookingId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel booking: $e',
      );
    }
  }
}

final bookingProvider =
    StateNotifierProvider.family<BookingNotifier, BookingState, String>((
      ref,
      userId,
    ) {
      final repository = ref.watch(bookingRepositoryProvider);
      return BookingNotifier(repository);
    });
