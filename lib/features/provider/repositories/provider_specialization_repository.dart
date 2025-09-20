import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/services/db_helper.dart';
import '../models/provider_specialization.dart';

class ProviderSpecializationRepository {
  final DBHelper _dbHelper = DBHelper.instance;
  final _specializationsController =
      StreamController<List<ProviderSpecialization>>.broadcast();

  // Create a new specialization
  Future<ProviderSpecialization> createSpecialization({
    required String name,
    required String description,
    required List<String> tags,
    Map<String, dynamic>? metadata,
  }) async {
    final specialization = ProviderSpecialization(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      tags: tags,
      isVerified: false,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    final db = await _dbHelper.database;
    await db.insert('specializations', specialization.toJson());
    _updateStream();
    return specialization;
  }

  // Get a specialization by ID
  Future<ProviderSpecialization?> getSpecializationById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'specializations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ProviderSpecialization.fromJson(maps.first);
  }

  // Update a specialization
  Future<void> updateSpecialization(
    ProviderSpecialization specialization,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'specializations',
      specialization.toJson(),
      where: 'id = ?',
      whereArgs: [specialization.id],
    );
    _updateStream();
  }

  // Delete a specialization
  Future<void> deleteSpecialization(String id) async {
    final db = await _dbHelper.database;
    await db.delete('specializations', where: 'id = ?', whereArgs: [id]);
    _updateStream();
  }

  // Get all specializations
  Stream<List<ProviderSpecialization>> getSpecializations({
    bool? isVerified,
    List<String>? tags,
  }) {
    _updateStream(isVerified: isVerified, tags: tags);
    return _specializationsController.stream;
  }

  Future<void> _updateStream({bool? isVerified, List<String>? tags}) async {
    final db = await _dbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (isVerified != null) {
      whereClause += ' AND isVerified = ?';
      whereArgs.add(isVerified ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'specializations',
      where: whereClause,
      whereArgs: whereArgs,
    );

    final specializations = maps.map(ProviderSpecialization.fromJson).toList();

    if (tags != null && tags.isNotEmpty) {
      specializations.removeWhere(
        (spec) => !tags.any((tag) => spec.tags.contains(tag)),
      );
    }

    _specializationsController.add(specializations);
  }

  // Verify a specialization
  Future<void> verifySpecialization(
    String id, {
    String? verificationDocument,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'specializations',
      {
        'isVerified': 1,
        'verifiedAt': DateTime.now().toIso8601String(),
        if (verificationDocument != null)
          'verificationDocument': verificationDocument,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _updateStream();
  }

  // Search specializations
  Future<List<ProviderSpecialization>> searchSpecializations(
    String query, {
    bool? isVerified,
    int limit = 10,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = 'name LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];

    if (isVerified != null) {
      whereClause += ' AND isVerified = ?';
      whereArgs.add(isVerified ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'specializations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
    );

    return maps.map(ProviderSpecialization.fromJson).toList();
  }

  // Get provider specializations
  Future<List<ProviderSpecialization>> getProviderSpecializations(
    String providerId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> providerSpecMaps = await db.query(
      'provider_specializations',
      where: 'providerId = ?',
      whereArgs: [providerId],
    );

    final specializationIds = providerSpecMaps
        .map((m) => m['specializationId'] as String)
        .toList();
    if (specializationIds.isEmpty) return [];

    final List<Map<String, dynamic>> specializationMaps = await db.query(
      'specializations',
      where: 'id IN (${List.filled(specializationIds.length, '?').join(',')})',
      whereArgs: specializationIds,
    );

    return specializationMaps.map(ProviderSpecialization.fromJson).toList();
  }

  // Add specialization to provider
  Future<void> addSpecializationToProvider(
    String providerId,
    String specializationId, {
    Map<String, dynamic>? metadata,
  }) async {
    final db = await _dbHelper.database;
    await db.insert('provider_specializations', {
      'providerId': providerId,
      'specializationId': specializationId,
      'addedAt': DateTime.now().toIso8601String(),
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _updateStream();
  }

  // Remove specialization from provider
  Future<void> removeSpecializationFromProvider(
    String providerId,
    String specializationId,
  ) async {
    final db = await _dbHelper.database;
    await db.delete(
      'provider_specializations',
      where: 'providerId = ? AND specializationId = ?',
      whereArgs: [providerId, specializationId],
    );
    _updateStream();
  }

  void dispose() {
    _specializationsController.close();
  }
}
