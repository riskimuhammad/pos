import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<Location>>> getLocations({
    required String tenantId,
    String? type,
    bool? isActive,
  });
  
  Future<Either<Failure, Location?>> getLocation(String locationId);
  
  Future<Either<Failure, Location?>> getPrimaryLocation(String tenantId);
  
  Future<Either<Failure, Location>> createLocation(Location location);
  
  Future<Either<Failure, Location>> updateLocation(Location location);
  
  Future<Either<Failure, void>> deleteLocation(String locationId);
}
