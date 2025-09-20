import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/currency_config.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> getUserCurrency() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'USD';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return 'USD';

      final data = userDoc.data();
      if (data == null) return 'USD';

      final countryCode = data['countryCode'] as String?;
      if (countryCode == null) return 'USD';

      return CurrencyConfig.getCurrencyCode(countryCode);
    } catch (e) {
      print('Error getting user currency: $e');
      return 'USD';
    }
  }

  static Future<void> updateUserCountry(String countryCode) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).set({
        'countryCode': countryCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user country: $e');
      rethrow;
    }
  }
}
