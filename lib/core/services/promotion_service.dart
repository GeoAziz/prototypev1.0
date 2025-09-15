import 'package:flutter/material.dart';
import '../models/promotion.dart';

class PromotionService {
  // Simulate fetching from backend
  Stream<List<Promotion>> streamPromotions() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield [
      Promotion(
        id: '1',
        title: 'Special Offer',
        subtitle: '25% Off First Booking',
        icon: Icons.favorite_outline,
        backgroundColor: Colors.blue,
        route: '/offers',
      ),
      Promotion(
        id: '2',
        title: 'Quick Service',
        subtitle: 'Book a service within 2 hours',
        icon: Icons.timer_outlined,
        backgroundColor: Colors.indigo,
        route: '/quick-service',
      ),
      Promotion(
        id: '3',
        title: 'Membership',
        subtitle: 'Get exclusive benefits',
        icon: Icons.wallet_outlined,
        backgroundColor: Colors.amber,
        route: '/membership',
      ),
    ];
  }
}
