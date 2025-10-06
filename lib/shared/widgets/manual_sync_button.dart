import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/sync/presentation/controllers/sync_controller.dart';

class ManualSyncButton extends StatelessWidget {
  final bool isCompact;
  final VoidCallback? onSyncComplete;

  const ManualSyncButton({
    super.key,
    this.isCompact = false,
    this.onSyncComplete,
  });

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return Obx(() {
      final isSyncing = syncController.isSyncing.value;
      final isOnline = syncController.isOnline.value;
      final hasPendingItems = syncController.pendingSyncItems.isNotEmpty;

      return ElevatedButton.icon(
        onPressed: isSyncing || !isOnline ? null : () => _performSync(syncController),
        icon: isSyncing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.sync),
        label: Text(
          isCompact
              ? (isSyncing ? 'Syncing...' : 'Sync')
              : (isSyncing
                  ? 'Syncing...'
                  : hasPendingItems
                      ? 'Sync Now (${syncController.pendingSyncItems.length})'
                      : 'Sync Now'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasPendingItems
              ? Colors.amber
              : Theme.of(context).colorScheme.primary,
          foregroundColor: hasPendingItems
              ? Colors.black
              : Theme.of(context).colorScheme.onPrimary,
        ),
      );
    });
  }

  Future<void> _performSync(SyncController syncController) async {
    await syncController.performManualSync();
    onSyncComplete?.call();
  }
}
