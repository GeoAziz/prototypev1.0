import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/availability_model.dart';
import '../repositories/availability_repository.dart';

part 'availability_stream_provider.g.dart';

@riverpod
Stream<Availability> availabilityStream(
  AvailabilityStreamRef ref,
  String providerId,
) {
  final repo = AvailabilityRepository();
  return repo.subscribeAvailability(providerId);
}
