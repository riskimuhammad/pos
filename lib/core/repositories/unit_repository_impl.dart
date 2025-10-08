import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/api/unit_api_service.dart';
import 'package:pos/core/repositories/unit_repository.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/constants/app_constants.dart';

class UnitRepositoryImpl implements UnitRepository {
  final LocalDataSource _localDataSource;
  final UnitApiService? _unitApiService;
  final NetworkInfo _networkInfo;

  UnitRepositoryImpl({
    required LocalDataSource localDataSource,
    UnitApiService? unitApiService,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _unitApiService = unitApiService,
       _networkInfo = networkInfo;

  @override
  Future<List<Unit>> getUnits() async {
    try {
      // Always get from local first
      final localUnits = await _localDataSource.getUnits();
      
      // If API is enabled and online, sync with server
      if (AppConstants.kEnableRemoteApi && 
          _unitApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await syncUnits();
          // Return updated local units after sync
          return await _localDataSource.getUnits();
        } catch (e) {
          print('⚠️ Failed to sync units, using local data: $e');
        }
      }
      
      return localUnits;
    } catch (e) {
      print('❌ Error getting units: $e');
      return [];
    }
  }

  @override
  Future<Unit?> getUnitById(String id) async {
    try {
      return await _localDataSource.getUnit(id);
    } catch (e) {
      print('❌ Error getting unit by ID: $e');
      return null;
    }
  }

  @override
  Future<Unit> createUnit(Unit unit) async {
    try {
      // Save to local first
      final createdUnit = await _localDataSource.createUnit(unit);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _unitApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await createUnitOnServer(createdUnit);
        } catch (e) {
          print('⚠️ Failed to sync unit to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'CREATE',
            'units',
            createdUnit.toJson(),
          );
        }
      }
      
      return createdUnit;
    } catch (e) {
      print('❌ Error creating unit: $e');
      rethrow;
    }
  }

  @override
  Future<Unit> updateUnit(Unit unit) async {
    try {
      // Update local first
      final updatedUnit = await _localDataSource.updateUnit(unit);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _unitApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await updateUnitOnServer(updatedUnit);
        } catch (e) {
          print('⚠️ Failed to sync unit update to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'UPDATE',
            'units',
            updatedUnit.toJson(),
          );
        }
      }
      
      return updatedUnit;
    } catch (e) {
      print('❌ Error updating unit: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      // Delete from local first
      await _localDataSource.deleteUnit(id);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _unitApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await deleteUnitFromServer(id);
        } catch (e) {
          print('⚠️ Failed to sync unit deletion to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'DELETE',
            'units',
            null,
            entityId: id,
          );
        }
      }
    } catch (e) {
      print('❌ Error deleting unit: $e');
      rethrow;
    }
  }

  @override
  Future<List<Unit>> searchUnits(String query) async {
    try {
      return await _localDataSource.searchUnits(query);
    } catch (e) {
      print('❌ Error searching units: $e');
      return [];
    }
  }

  @override
  Future<bool> unitNameExists(String name, {String? excludeId}) async {
    try {
      return await _localDataSource.unitNameExists(name, excludeId: excludeId);
    } catch (e) {
      print('❌ Error checking unit name: $e');
      return false;
    }
  }

  @override
  Future<void> syncUnits() async {
    if (!AppConstants.kEnableRemoteApi || _unitApiService == null) {
      print('⚠️ API sync disabled, skipping unit sync');
      return;
    }

    try {
      // Get units from server
      final serverUnits = await getUnitsFromServer();
      
      // Get local units
      final localUnits = await _localDataSource.getUnits();
      
      // Sync logic: update local with server data
      for (final serverUnit in serverUnits) {
        final localUnit = localUnits.firstWhere(
          (unit) => unit.id == serverUnit.id,
          orElse: () => Unit(
            id: '',
            tenantId: '',
            name: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (localUnit.id.isEmpty) {
          // New unit from server, add to local
          await _localDataSource.createUnit(serverUnit);
        } else if (serverUnit.updatedAt.isAfter(localUnit.updatedAt)) {
          // Server has newer version, update local
          await _localDataSource.updateUnit(serverUnit);
        }
      }
      
      print('✅ Units synced successfully');
    } catch (e) {
      print('❌ Error syncing units: $e');
      rethrow;
    }
  }

  @override
  Future<List<Unit>> getUnitsFromServer() async {
    if (_unitApiService == null) {
      throw Exception('UnitApiService not available');
    }
    
    try {
      return await _unitApiService.getUnits(
        tenantId: AppConstants.defaultTenantId,
      );
    } catch (e) {
      print('❌ Error getting units from server: $e');
      rethrow;
    }
  }

  @override
  Future<Unit> createUnitOnServer(Unit unit) async {
    if (_unitApiService == null) {
      throw Exception('UnitApiService not available');
    }
    
    try {
      return await _unitApiService.createUnit(unit);
    } catch (e) {
      print('❌ Error creating unit on server: $e');
      rethrow;
    }
  }

  @override
  Future<Unit> updateUnitOnServer(Unit unit) async {
    if (_unitApiService == null) {
      throw Exception('UnitApiService not available');
    }
    
    try {
      return await _unitApiService.updateUnit(unit);
    } catch (e) {
      print('❌ Error updating unit on server: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUnitFromServer(String id) async {
    if (_unitApiService == null) {
      throw Exception('UnitApiService not available');
    }
    
    try {
      await _unitApiService.deleteUnit(id);
    } catch (e) {
      print('❌ Error deleting unit from server: $e');
      rethrow;
    }
  }
}
