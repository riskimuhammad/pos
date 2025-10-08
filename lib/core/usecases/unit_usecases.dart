import 'package:pos/core/repositories/unit_repository.dart';
import 'package:pos/shared/models/entities/entities.dart';

class GetUnitsUseCase {
  final UnitRepository _repository;

  GetUnitsUseCase(this._repository);

  Future<List<Unit>> call() async {
    return await _repository.getUnits();
  }
}

class CreateUnitUseCase {
  final UnitRepository _repository;

  CreateUnitUseCase(this._repository);

  Future<Unit> call(Unit unit) async {
    // Validate unit name
    if (unit.name.trim().isEmpty) {
      throw Exception('Unit name cannot be empty');
    }
    
    if (unit.name.trim().length < 2) {
      throw Exception('Unit name must be at least 2 characters');
    }
    
    // Check if unit name already exists
    final nameExists = await _repository.unitNameExists(unit.name.trim());
    if (nameExists) {
      throw Exception('Unit name already exists');
    }
    
    return await _repository.createUnit(unit);
  }
}

class UpdateUnitUseCase {
  final UnitRepository _repository;

  UpdateUnitUseCase(this._repository);

  Future<Unit> call(Unit unit) async {
    // Validate unit name
    if (unit.name.trim().isEmpty) {
      throw Exception('Unit name cannot be empty');
    }
    
    if (unit.name.trim().length < 2) {
      throw Exception('Unit name must be at least 2 characters');
    }
    
    // Check if unit name already exists (excluding current unit)
    final nameExists = await _repository.unitNameExists(
      unit.name.trim(),
      excludeId: unit.id,
    );
    if (nameExists) {
      throw Exception('Unit name already exists');
    }
    
    return await _repository.updateUnit(unit);
  }
}

class DeleteUnitUseCase {
  final UnitRepository _repository;

  DeleteUnitUseCase(this._repository);

  Future<void> call(String unitId) async {
    if (unitId.trim().isEmpty) {
      throw Exception('Unit ID cannot be empty');
    }
    
    return await _repository.deleteUnit(unitId);
  }
}

class SearchUnitsUseCase {
  final UnitRepository _repository;

  SearchUnitsUseCase(this._repository);

  Future<List<Unit>> call(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getUnits();
    }
    
    return await _repository.searchUnits(query.trim());
  }
}
