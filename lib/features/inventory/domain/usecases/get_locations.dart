import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class GetLocations {
  final LocationRepository repository;

  GetLocations(this.repository);

  Future<Either<Failure, List<Location>>> call(GetLocationsParams params) async {
    try {
      final locations = await repository.getLocations(
        tenantId: params.tenantId,
        type: params.type,
        isActive: params.isActive,
      );
      return locations;
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class GetLocationsParams {
  final String tenantId;
  final String? type;
  final bool? isActive;

  GetLocationsParams({
    required this.tenantId,
    this.type,
    this.isActive,
  });
}
