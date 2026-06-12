import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/sync_controller.dart';


class ConnectivityBanner extends ConsumerWidget {

  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BannerStatus status = ref.watch(bannerStatusProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, IconData icon, String label) =
        switch (status) {
      BannerStatus.online => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.cloud_done_outlined,
          'Online',
        ),
      BannerStatus.offline => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.cloud_off_outlined,
          'Offline — showing cached data',
        ),
      BannerStatus.syncing => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.sync,
          'Syncing…',
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,

      color:  background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
