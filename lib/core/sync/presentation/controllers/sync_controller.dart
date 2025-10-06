import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/sync_queue.dart';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncController extends GetxController {
  final SyncRepository syncRepository;
  final Connectivity connectivity;

  SyncController({
    required this.syncRepository,
    required this.connectivity,
  });

  // Observable states
  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final Rx<SyncStatus> syncStatus = SyncStatus(
    id: 'default',
    lastSyncTimestamp: DateTime.now(),
    syncVersion: '1.0.0',
  ).obs;
  final RxList<SyncQueue> pendingSyncItems = <SyncQueue>[].obs;
  final RxString lastSyncError = ''.obs;

  // Timers
  Timer? _periodicSyncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
    _loadSyncStatus();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  // Setup connectivity monitoring
  void _setupConnectivityListener() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = isOnline.value;
      isOnline.value = result != ConnectivityResult.none;
      
      // Auto sync when coming online
      if (!wasOnline && isOnline.value) {
        _performAutoSync();
      }
      
      // Update sync status
      _updateSyncStatus();
    });
  }

  // Load initial sync status
  Future<void> _loadSyncStatus() async {
    final result = await syncRepository.getSyncStatus();
    result.fold(
      (failure) => print('Failed to load sync status: $failure'),
      (status) {
        syncStatus.value = status;
        isOnline.value = status.isOnline;
      },
    );

    await _loadPendingItems();
  }

  // Load pending sync items
  Future<void> _loadPendingItems() async {
    final result = await syncRepository.getPendingSyncItems();
    result.fold(
      (failure) => print('Failed to load pending items: $failure'),
      (items) => pendingSyncItems.assignAll(items),
    );
  }

  // Start periodic sync (every 5 minutes when online)
  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (isOnline.value && !isSyncing.value) {
        _performAutoSync();
      }
    });
  }

  // Perform automatic sync
  Future<void> _performAutoSync() async {
    if (isSyncing.value || !isOnline.value) return;

    isSyncing.value = true;
    lastSyncError.value = '';

    try {
      final result = await syncRepository.performSync();
      result.fold(
        (failure) {
          lastSyncError.value = failure.message;
          Get.snackbar(
            'Sync Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        (_) async {
          // Success
          await _loadSyncStatus();
          Get.snackbar(
            'Sync Success',
            'Data synchronized successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
            duration: Duration(seconds: 2),
          );
        },
      );
    } catch (e) {
      lastSyncError.value = e.toString();
    } finally {
      isSyncing.value = false;
    }
  }

  // Perform manual sync
  Future<void> performManualSync() async {
    if (isSyncing.value) return;

    isSyncing.value = true;
    lastSyncError.value = '';

    try {
      final result = await syncRepository.performManualSync();
      result.fold(
        (failure) {
          lastSyncError.value = failure.message;
          Get.snackbar(
            'Manual Sync Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        },
        (_) async {
          // Success
          await _loadSyncStatus();
          Get.snackbar(
            'Manual Sync Success',
            'Data synchronized and cleaned up successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
            duration: Duration(seconds: 3),
          );
        },
      );
    } catch (e) {
      lastSyncError.value = e.toString();
    } finally {
      isSyncing.value = false;
    }
  }

  // Add item to sync queue
  Future<void> addToSyncQueue({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final result = await syncRepository.addToSyncQueue(
      tableName: tableName,
      operation: operation,
      data: data,
    );

    result.fold(
      (failure) => print('Failed to add to sync queue: $failure'),
      (_) => _loadPendingItems(),
    );
  }

  // Update sync status
  Future<void> _updateSyncStatus() async {
    final result = await syncRepository.getSyncStatus();
    result.fold(
      (failure) => print('Failed to update sync status: $failure'),
      (status) => syncStatus.value = status.copyWith(isOnline: isOnline.value),
    );
  }

  // Clear synced items
  Future<void> clearSyncedItems() async {
    final result = await syncRepository.clearSyncedItems();
    result.fold(
      (failure) => Get.snackbar('Error', 'Failed to clear synced items'),
      (_) {
        _loadPendingItems();
        Get.snackbar('Success', 'Synced items cleared');
      },
    );
  }

  // Get sync statistics
  Map<String, dynamic> getSyncStats() {
    final pendingByTable = <String, int>{};
    for (final item in pendingSyncItems) {
      pendingByTable[item.tableName] = (pendingByTable[item.tableName] ?? 0) + 1;
    }

    return {
      'total_pending': pendingSyncItems.length,
      'pending_by_table': pendingByTable,
      'last_sync': syncStatus.value.lastSyncTimestamp,
      'is_online': isOnline.value,
      'is_syncing': isSyncing.value,
    };
  }
}
