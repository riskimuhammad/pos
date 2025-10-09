import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/location_repository.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/repositories/base_repository.dart';
import 'package:dartz/dartz.dart';

class LocationRepositoryImpl extends BaseRepository implements LocationRepository {
  final LocalDataSource localDataSource;

  LocationRepositoryImpl({
    required NetworkInfo networkInfo,
    required this.localDataSource,
  }) : super(networkInfo);

  @override
  Future<Either<Failure, List<Location>>> getLocations({
    required String tenantId,
    String? type,
    bool? isActive,
  }) async {
    return await handleDatabaseOperation(() async {
      final locations = await localDataSource.getLocationsByTenant(tenantId);
      
      // Apply filters
      var filteredLocations = locations;
      
      if (type != null) {
        filteredLocations = filteredLocations.where((location) => location.type == type).toList();
      }
      
      if (isActive != null) {
        filteredLocations = filteredLocations.where((location) => location.isActive == isActive).toList();
      }
      
      return Right(filteredLocations);
    });
  }

  @override
  Future<Either<Failure, Location?>> getLocation(String locationId) async {
    return await handleDatabaseOperation(() async {
      final location = await localDataSource.getLocation(locationId);
      return Right(location);
    });
  }

  @override
  Future<Either<Failure, Location?>> getPrimaryLocation(String tenantId) async {
    return await handleDatabaseOperation(() async {
      final location = await localDataSource.getPrimaryLocation(tenantId);
      return Right(location);
    });
  }

  @override
  Future<Either<Failure, Location>> createLocation(Location location) async {
    return await handleDatabaseOperation(() async {
      final createdLocation = await localDataSource.createLocation(location);
      return Right(createdLocation);
    });
  }

  @override
  Future<Either<Failure, Location>> updateLocation(Location location) async {
    return await handleDatabaseOperation(() async {
      final updatedLocation = await localDataSource.updateLocation(location);
      return Right(updatedLocation);
    });
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    return await handleDatabaseOperation(() async {
      await localDataSource.deleteLocation(locationId);
      return const Right(null);
    });
  }
}
