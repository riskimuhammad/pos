import 'package:get/get.dart';
import 'package:pos/features/inventory/domain/repositories/location_repository.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class LocationController extends GetxController {
  final LocationRepository locationRepository;

  LocationController({required this.locationRepository});

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Location> locations = <Location>[].obs;

  String get _currentTenantId {
    try {
      final auth = Get.find<AuthController>();
      final session = auth.currentSession.value;
      if (session != null && session.tenant.id.isNotEmpty) return session.tenant.id;
    } catch (_) {}
    return 'default-tenant-id';
  }

  @override
  void onInit() {
    super.onInit();
    loadLocations();
  }

  Future<void> loadLocations() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await locationRepository.getLocations(tenantId: _currentTenantId);
    result.fold((failure) {
      errorMessage.value = failure.message;
      locations.clear();
    }, (data) {
      locations.assignAll(data);
    });
    isLoading.value = false;
  }

  Future<void> createLocation({
    required String name,
    String type = 'store',
    String? address,
    bool isPrimary = false,
    bool isActive = true,
  }) async {
    isLoading.value = true;
    final location = Location(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: _currentTenantId,
      name: name.trim(),
      type: type,
      address: address,
      isPrimary: isPrimary,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
      syncStatus: 'pending',
      lastSyncedAt: null,
    );
    final result = await locationRepository.createLocation(location);
    result.fold((failure) {
      errorMessage.value = failure.message;
    }, (created) {
      locations.add(created);
    });
    isLoading.value = false;
  }

  Future<void> updateLocation(Location location) async {
    isLoading.value = true;
    final updated = location.copyWith(updatedAt: DateTime.now());
    final result = await locationRepository.updateLocation(updated);
    result.fold((failure) {
      errorMessage.value = failure.message;
    }, (loc) {
      final idx = locations.indexWhere((l) => l.id == loc.id);
      if (idx != -1) locations[idx] = loc;
    });
    isLoading.value = false;
  }

  Future<void> deleteLocation(String locationId) async {
    isLoading.value = true;
    final result = await locationRepository.deleteLocation(locationId);
    result.fold((failure) {
      errorMessage.value = failure.message;
    }, (_) {
      locations.removeWhere((l) => l.id == locationId);
    });
    isLoading.value = false;
  }

  Future<void> setPrimary(String locationId) async {
    // Ensure single primary: unset others, set this one
    for (final loc in locations) {
      final shouldBePrimary = loc.id == locationId;
      if (loc.isPrimary != shouldBePrimary) {
        await updateLocation(loc.copyWith(isPrimary: shouldBePrimary));
      }
    }
  }

  Future<void> toggleActive(Location loc) async {
    await updateLocation(loc.copyWith(isActive: !loc.isActive));
  }
}


