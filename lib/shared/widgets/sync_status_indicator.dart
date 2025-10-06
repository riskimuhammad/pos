import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/sync/presentation/controllers/sync_controller.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool showText;
  final double iconSize;
  final double textSize;

  const SyncStatusIndicator({
    super.key,
    this.showText = true,
    this.iconSize = 16.0,
    this.textSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return Obx(() {
      if (syncController.isSyncing.value) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (showText) ...[
              SizedBox(width: 8),
              Text(
                'Syncing...',
                style: TextStyle(
                  fontSize: textSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        );
      } else if (!syncController.isOnline.value) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: iconSize,
              color: Colors.orange,
            ),
            if (showText) ...[
              SizedBox(width: 8),
              Text(
                'Offline',
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        );
      } else if (syncController.pendingSyncItems.isNotEmpty) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sync_problem,
              size: iconSize,
              color: Colors.amber,
            ),
            if (showText) ...[
              SizedBox(width: 8),
              Text(
                '${syncController.pendingSyncItems.length} pending',
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.amber,
                ),
              ),
            ],
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done,
              size: iconSize,
              color: Colors.green,
            ),
            if (showText) ...[
              SizedBox(width: 8),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        );
      }
    });
  }
}
