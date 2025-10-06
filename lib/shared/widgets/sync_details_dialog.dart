import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/sync/presentation/controllers/sync_controller.dart';
import 'manual_sync_button.dart';

class SyncDetailsDialog extends StatelessWidget {
  const SyncDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return Dialog(
      child: Container(
        width: Get.width * 0.9,
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, size: 28),
                SizedBox(width: 12),
                Text(
                  'Sync Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 24),
            Obx(() => _buildSyncStatus(context, syncController)),
            SizedBox(height: 24),
            _buildSyncActions(context, syncController),
            SizedBox(height: 24),
            _buildPendingItems(context, syncController),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context, SyncController syncController) {
    final status = syncController.syncStatus.value;
    final isOnline = syncController.isOnline.value;
    final isSyncing = syncController.isSyncing.value;
    final pendingCount = syncController.pendingSyncItems.length;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildStatusRow(
              'Connection',
              isOnline ? 'Online' : 'Offline',
              isOnline ? Colors.green : Colors.red,
            ),
            _buildStatusRow(
              'Sync Status',
              isSyncing ? 'Syncing...' : 'Idle',
              isSyncing ? Colors.blue : Colors.grey,
            ),
            _buildStatusRow(
              'Pending Items',
              '$pendingCount items',
              pendingCount > 0 ? Colors.amber : Colors.green,
            ),
            _buildStatusRow(
              'Last Sync',
              DateFormat('dd/MM/yyyy HH:mm').format(status.lastSyncTimestamp),
              Colors.grey,
            ),
            _buildStatusRow(
              'Sync Version',
              status.syncVersion,
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncActions(BuildContext context, SyncController syncController) {
    return Row(
      children: [
        Expanded(
          child: ManualSyncButton(
            onSyncComplete: () => Get.back(),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showClearDialog(syncController),
            icon: Icon(Icons.clear_all),
            label: Text('Clear Synced'),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingItems(BuildContext context, SyncController syncController) {
    return Obx(() {
      final pendingItems = syncController.pendingSyncItems;
      
      if (pendingItems.isEmpty) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 48, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    'No pending sync items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pending Items (${pendingItems.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: pendingItems.length,
                itemBuilder: (context, index) {
                  final item = pendingItems[index];
                  return ListTile(
                    leading: Icon(
                      _getOperationIcon(item.operation),
                      color: _getOperationColor(item.operation),
                    ),
                    title: Text('${item.tableName} - ${item.operation}'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp),
                    ),
                    trailing: item.retryCount > 0
                        ? Chip(
                            label: Text('Retry ${item.retryCount}'),
                            backgroundColor: Colors.orange,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  IconData _getOperationIcon(String operation) {
    switch (operation.toUpperCase()) {
      case 'CREATE':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.sync;
    }
  }

  Color _getOperationColor(String operation) {
    switch (operation.toUpperCase()) {
      case 'CREATE':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showClearDialog(SyncController syncController) {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Synced Items'),
        content: Text(
          'This will remove all successfully synced items from the queue. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              syncController.clearSyncedItems();
              Get.back();
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}
