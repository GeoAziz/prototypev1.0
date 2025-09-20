import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_flutter_project/features/provider/models/booking_model.dart';

void main() {
  test('Booking model serialization', () {
    final booking = Booking(
      id: 'b1',
      providerId: 'p1',
      userId: 'u1',
      date: DateTime.now(),
      status: 'completed',
      price: 1000.0,
    );
    final json = booking.toJson();
    final fromJson = Booking.fromJson(json);
    expect(fromJson.id, booking.id);
    expect(fromJson.status, booking.status);
  });
}
