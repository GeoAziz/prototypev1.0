import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/provider_registration_model.dart';
import 'package:poafix/core/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ProviderRegistrationModel> registerProvider({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? businessName,
  }) async {
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get location
      GeoPoint? location;
      try {
        final locationService = LocationService();
        final position = await locationService.getCurrentLocation();
        location = GeoPoint(position.latitude, position.longitude);
      } catch (e) {
        location = null;
      }

      // Create initial provider model
      final provider = ProviderRegistrationModel(
        uid: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        businessName: businessName,
        location: location,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(provider.toMap());

      return provider;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPortfolioImages({
    required String uid,
    required List<File> images,
  }) async {
    try {
      final List<String> urls = [];

      for (final image in images) {
        final ref = _storage.ref().child(
          'providers/$uid/portfolio/${DateTime.now().millisecondsSinceEpoch}',
        );
        final uploadTask = await ref.putFile(image);
        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      }

      await _firestore.collection('users').doc(uid).update({
        'portfolioUrls': FieldValue.arrayUnion(urls),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadVerificationDocuments({
    required String uid,
    required List<File> documents,
  }) async {
    try {
      final List<String> urls = [];

      for (final doc in documents) {
        final ref = _storage.ref().child(
          'providers/$uid/verification/${DateTime.now().millisecondsSinceEpoch}',
        );
        final uploadTask = await ref.putFile(doc);
        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      }

      await _firestore.collection('users').doc(uid).update({
        'verificationDocUrls': FieldValue.arrayUnion(urls),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProviderProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProfilePhoto({
    required String uid,
    required File photo,
  }) async {
    try {
      final ref = _storage.ref().child(
        'providers/$uid/profile/${DateTime.now().millisecondsSinceEpoch}',
      );
      final uploadTask = await ref.putFile(photo);
      final url = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'profilePhotoUrl': url,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAvailability({
    required String uid,
    required Map<String, List<String>> availability,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'availability': availability,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBankDetails({
    required String uid,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'bankDetails': bankDetails,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
