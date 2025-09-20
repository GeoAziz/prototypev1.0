import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/provider.dart';
import '../services/db_helper.dart';

class ProviderRepository {
  final _controller = StreamController<List<Provider>>.broadcast();
  final DBHelper _dbHelper = DBHelper.instance;

  Stream<List<Provider>> get providersStream => _controller.stream;

  Future<void> addProvider(Provider provider) async {
    final db = await _dbHelper.database;
    await db.insert(
      'providers',
      provider.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _updateStream();
  }

  Future<void> updateProvider(Provider provider) async {
    final db = await _dbHelper.database;
    await db.update(
      'providers',
      provider.toJson(),
      where: 'id = ?',
      whereArgs: [provider.id],
    );
    _updateStream();
  }

  Future<Provider?> getProvider(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'providers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Provider.fromJson(maps.first);
  }

  Future<void> deleteProvider(String id) async {
    final db = await _dbHelper.database;
    await db.delete('providers', where: 'id = ?', whereArgs: [id]);
    _updateStream();
  }

  Future<void> _updateStream() async {
    final providers = await _dbHelper.getProviders();
    _controller.add(providers);
  }

  void dispose() {
    _controller.close();
  }
}
