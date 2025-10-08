import 'package:get/get.dart';
import 'package:pos/core/usecases/unit_usecases.dart';
import 'package:pos/shared/models/entities/entities.dart';

class UnitController extends GetxController {
  final GetUnitsUseCase _getUnitsUseCase;
  final CreateUnitUseCase _createUnitUseCase;
  final UpdateUnitUseCase _updateUnitUseCase;
  final DeleteUnitUseCase _deleteUnitUseCase;
  final SearchUnitsUseCase _searchUnitsUseCase;

  UnitController({
    required GetUnitsUseCase getUnitsUseCase,
    required CreateUnitUseCase createUnitUseCase,
    required UpdateUnitUseCase updateUnitUseCase,
    required DeleteUnitUseCase deleteUnitUseCase,
    required SearchUnitsUseCase searchUnitsUseCase,
  }) : _getUnitsUseCase = getUnitsUseCase,
       _createUnitUseCase = createUnitUseCase,
       _updateUnitUseCase = updateUnitUseCase,
       _deleteUnitUseCase = deleteUnitUseCase,
       _searchUnitsUseCase = searchUnitsUseCase;

  // Observable state
  final RxList<Unit> _units = <Unit>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<Unit> _filteredUnits = <Unit>[].obs;

  // Getters
  List<Unit> get units => _units;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  List<Unit> get filteredUnits => _filteredUnits;

  @override
  void onInit() {
    super.onInit();
    loadUnits();
  }

  /// Load all units
  Future<void> loadUnits() async {
    try {
      _isLoading.value = true;
      final units = await _getUnitsUseCase();
      _units.assignAll(units);
      _filteredUnits.assignAll(units);
    } catch (e) {
      print('❌ Error loading units: $e');
      Get.snackbar(
        'Error',
        'Failed to load units: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create new unit
  Future<void> createUnit(Unit unit) async {
    try {
      _isLoading.value = true;
      final createdUnit = await _createUnitUseCase(unit);
      _units.add(createdUnit);
      _filteredUnits.add(createdUnit);
      
      Get.snackbar(
        'Success',
        'Unit created successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ Error creating unit: $e');
      Get.snackbar(
        'Error',
        'Failed to create unit: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update unit
  Future<void> updateUnit(Unit unit) async {
    try {
      _isLoading.value = true;
      final updatedUnit = await _updateUnitUseCase(unit);
      
      // Update in lists
      final index = _units.indexWhere((u) => u.id == unit.id);
      if (index != -1) {
        _units[index] = updatedUnit;
      }
      
      final filteredIndex = _filteredUnits.indexWhere((u) => u.id == unit.id);
      if (filteredIndex != -1) {
        _filteredUnits[filteredIndex] = updatedUnit;
      }
      
      Get.snackbar(
        'Success',
        'Unit updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ Error updating unit: $e');
      Get.snackbar(
        'Error',
        'Failed to update unit: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete unit
  Future<void> deleteUnit(String unitId) async {
    try {
      _isLoading.value = true;
      await _deleteUnitUseCase(unitId);
      
      // Remove from lists
      _units.removeWhere((u) => u.id == unitId);
      _filteredUnits.removeWhere((u) => u.id == unitId);
      
      Get.snackbar(
        'Success',
        'Unit deleted successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ Error deleting unit: $e');
      Get.snackbar(
        'Error',
        'Failed to delete unit: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Search units
  Future<void> searchUnits(String query) async {
    try {
      _searchQuery.value = query;
      
      if (query.trim().isEmpty) {
        _filteredUnits.assignAll(_units);
        return;
      }
      
      final results = await _searchUnitsUseCase(query);
      _filteredUnits.assignAll(results);
    } catch (e) {
      print('❌ Error searching units: $e');
      Get.snackbar(
        'Error',
        'Failed to search units: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _filteredUnits.assignAll(_units);
  }

  /// Get unit by ID
  Unit? getUnitById(String id) {
    try {
      return _units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get unit by name
  Unit? getUnitByName(String name) {
    try {
      return _units.firstWhere((unit) => unit.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Refresh units
  Future<void> refreshUnits() async {
    await loadUnits();
  }
}
