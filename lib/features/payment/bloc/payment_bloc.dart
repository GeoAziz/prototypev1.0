import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentBloc {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getPaymentMethods() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addPaymentMethod({
    required String type,
    required String last4,
    required String expiry,
    bool isDefault = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.uid);
    final paymentMethodsRef = userRef.collection('payment_methods');

    if (isDefault) {
      // Get all payment methods
      final paymentMethods = await paymentMethodsRef.get();
      // Set all existing payment methods to non-default
      for (final doc in paymentMethods.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    // Add new payment method
    final newPaymentMethodRef = paymentMethodsRef.doc();
    batch.set(newPaymentMethodRef, {
      'type': type,
      'last4': last4,
      'expiry': expiry,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.uid);
    final paymentMethodsRef = userRef.collection('payment_methods');

    // Get all payment methods
    final paymentMethods = await paymentMethodsRef.get();

    // Update default status for all payment methods
    for (final doc in paymentMethods.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == paymentMethodId});
    }

    await batch.commit();
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .doc(paymentMethodId)
        .delete();
  }

  Future<Map<String, dynamic>?> getDefaultPaymentMethod() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.data();
  }
}
