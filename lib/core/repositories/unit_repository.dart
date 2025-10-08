import 'package:pos/shared/models/entities/entities.dart';

abstract class UnitRepository {
  /// Get all units
  Future<List<Unit>> getUnits();

  /// Get unit by ID
  Future<Unit?> getUnitById(String id);

  /// Create new unit
  Future<Unit> createUnit(Unit unit);

  /// Update unit
  Future<Unit> updateUnit(Unit unit);

  /// Delete unit
  Future<void> deleteUnit(String id);

  /// Search units by name
  Future<List<Unit>> searchUnits(String query);

  /// Check if unit name exists
  Future<bool> unitNameExists(String name, {String? excludeId});

  /// Sync units with server
  Future<void> syncUnits();

  /// Get units from server
  Future<List<Unit>> getUnitsFromServer();

  /// Create unit on server
  Future<Unit> createUnitOnServer(Unit unit);

  /// Update unit on server
  Future<Unit> updateUnitOnServer(Unit unit);

  /// Delete unit from server
  Future<void> deleteUnitFromServer(String id);
}
