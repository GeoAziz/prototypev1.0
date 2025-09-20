import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking.dart';
import '../models/provider.dart';
import '../models/location.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('poafix.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookings(
        id TEXT PRIMARY KEY,
        serviceTitle TEXT NOT NULL,
        provider TEXT NOT NULL,
        status TEXT NOT NULL,
        bookedAt TEXT NOT NULL,
        userId TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityId TEXT NOT NULL,
        entityType TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        UNIQUE(entityId, entityType)
      )
    ''');

    await db.execute('''
      CREATE TABLE providers(
        id TEXT PRIMARY KEY,
        businessName TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        description TEXT,
        rating REAL DEFAULT 0,
        ratingCount INTEGER DEFAULT 0,
        isActive BOOLEAN DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastUpdated TEXT,
        serviceCategories TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE specializations(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        tags TEXT NOT NULL,
        isVerified BOOLEAN DEFAULT 0,
        createdAt TEXT NOT NULL,
        verifiedAt TEXT,
        verificationDocument TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE provider_specializations(
        providerId TEXT NOT NULL,
        specializationId TEXT NOT NULL,
        addedAt TEXT NOT NULL,
        metadata TEXT,
        PRIMARY KEY (providerId, specializationId),
        FOREIGN KEY (providerId) REFERENCES providers(id) ON DELETE CASCADE,
        FOREIGN KEY (specializationId) REFERENCES specializations(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        route TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead BOOLEAN DEFAULT 0
      )
    ''');
  }

  // Booking operations
  Future<int> insertBooking(Booking booking) async {
    final db = await instance.database;
    return db.insert(
      'bookings',
      booking.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Booking>> getBookings() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) => Booking.fromSqlite(maps[i]));
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Booking.fromSqlite(maps[i]));
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await instance.database;
    return db.update(
      'bookings',
      booking.toSqlite(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(String id) async {
    final db = await instance.database;
    return db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // Location operations
  Future<void> updateLocation({
    required String entityId,
    required String entityType,
    required double latitude,
    required double longitude,
  }) async {
    final db = await instance.database;
    await db.insert('locations', {
      'entityId': entityId,
      'entityType': entityType,
      'latitude': latitude,
      'longitude': longitude,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getLocation(
    String entityId,
    String entityType,
  ) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'locations',
      where: 'entityId = ? AND entityType = ?',
      whereArgs: [entityId, entityType],
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<void> deleteLocation(String entityId, String entityType) async {
    final db = await instance.database;
    await db.delete(
      'locations',
      where: 'entityId = ? AND entityType = ?',
      whereArgs: [entityId, entityType],
    );
  }

  Future<List<Provider>> getProviders() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> providerMaps = await db.query('providers');
    final List<Map<String, dynamic>> locationMaps = await db.query(
      'locations',
      where: 'entityType = ?',
      whereArgs: ['provider'],
    );

    // Create a map of provider IDs to their locations
    final locationMap = {
      for (var loc in locationMaps)
        loc['entityId'] as String: Location(
          latitude: loc['latitude'] as double,
          longitude: loc['longitude'] as double,
        ),
    };

    return providerMaps.map((map) {
      final providerId = map['id'] as String;
      return Provider.fromJson({...map, 'location': locationMap[providerId]});
    }).toList();
  }

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await instance.database;
    // Convert data map to JSON string for storage
    final data = notification['data'];
    final notificationToStore = {
      ...notification,
      'data': data is String ? data : jsonEncode(data),
    };
    return db.insert(
      'notifications',
      notificationToStore,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> notifications = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    // Convert stored JSON string back to map
    return notifications.map((notification) {
      final data = notification['data'];
      try {
        notification['data'] = jsonDecode(data as String);
      } catch (e) {
        // If data is already a map or can't be decoded, leave it as is
        print('Error decoding notification data: $e');
      }
      return notification;
    }).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await instance.database;
    return db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await instance.database;
    return db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
