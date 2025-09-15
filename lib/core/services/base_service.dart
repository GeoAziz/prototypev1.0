import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/exceptions/service_exception.dart';

abstract class BaseService {
  final FirebaseFirestore _firestore;

  BaseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  Future<T> handleServiceCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (e) {
      throw ServiceException(
        e.message ?? 'An error occurred',
        code: e.code,
        error: e,
      );
    } catch (e) {
      throw ServiceException('An unexpected error occurred', error: e);
    }
  }

  Stream<T> handleServiceStream<T>(Stream<T> stream) {
    return stream.handleError((error) {
      if (error is FirebaseException) {
        throw ServiceException(
          error.message ?? 'An error occurred',
          code: error.code,
          error: error,
        );
      }
      throw ServiceException('An unexpected error occurred', error: error);
    });
  }
}
