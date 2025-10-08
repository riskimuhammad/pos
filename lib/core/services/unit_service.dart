import 'package:get/get.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/constants/app_constants.dart';

class UnitService {
  final DatabaseHelper _databaseHelper = Get.find<DatabaseHelper>();

  /// Get all units
  Future<List<Unit>> getAllUnits() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'units',
        where: 'deleted_at IS NULL AND is_active = 1',
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return Unit.fromJson(maps[i]);
      });
    } catch (e) {
      print('❌ Error getting units: $e');
      return [];
    }
  }

  /// Get unit by ID
  Future<Unit?> getUnitById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'units',
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Unit.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting unit by ID: $e');
      return null;
    }
  }

  /// Create new unit
  Future<Unit> createUnit(Unit unit) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('units', unit.toJson());
      print('✅ Unit created: ${unit.name}');
      return unit;
    } catch (e) {
      print('❌ Error creating unit: $e');
      rethrow;
    }
  }

  /// Update unit
  Future<Unit> updateUnit(Unit unit) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'units',
        unit.toJson(),
        where: 'id = ?',
        whereArgs: [unit.id],
      );
      print('✅ Unit updated: ${unit.name}');
      return unit;
    } catch (e) {
      print('❌ Error updating unit: $e');
      rethrow;
    }
  }

  /// Delete unit (soft delete)
  Future<void> deleteUnit(String id) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'units',
        {
          'deleted_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      print('✅ Unit deleted: $id');
    } catch (e) {
      print('❌ Error deleting unit: $e');
      rethrow;
    }
  }

  /// Search units by name
  Future<List<Unit>> searchUnits(String query) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'units',
        where: 'name LIKE ? AND deleted_at IS NULL AND is_active = 1',
        whereArgs: ['%$query%'],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return Unit.fromJson(maps[i]);
      });
    } catch (e) {
      print('❌ Error searching units: $e');
      return [];
    }
  }

  /// Check if unit name exists
  Future<bool> unitNameExists(String name, {String? excludeId}) async {
    try {
      final db = await _databaseHelper.database;
      String whereClause = 'name = ? AND deleted_at IS NULL';
      List<dynamic> whereArgs = [name];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'units',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return maps.isNotEmpty;
    } catch (e) {
      print('❌ Error checking unit name: $e');
      return false;
    }
  }

}
