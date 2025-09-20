import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/models/service.dart';

class ServiceQueryResult {
  final List<Service> services;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  ServiceQueryResult({
    required this.services,
    this.lastDocument,
    required this.hasMore,
  });
}
