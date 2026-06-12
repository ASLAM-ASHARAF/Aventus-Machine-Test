import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/sync_controller.dart';


class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncState sync = ref.watch(syncControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final String lastSync = sync.lastSyncAt == null
        ? 'Never'
        : DateFormat('MMM d, h:mm a').format(sync.lastSyncAt!);

    final (Color color, String label) = switch (sync.status) {
      SyncStatus.idle => (scheme.outline, 'Idle'),
      SyncStatus.syncing => (scheme.tertiary, 'Syncing…'),
      SyncStatus.success => (scheme.primary, 'Up to date'),
      SyncStatus.failure => (scheme.error, 'Sync failed'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          Icon(Icons.history, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Last sync: $lastSync',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
