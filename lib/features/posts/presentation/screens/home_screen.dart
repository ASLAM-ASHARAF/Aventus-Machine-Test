import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/presentation/screens/theme_screen.dart';
import '../controllers/sync_controller.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/post_list.dart';
import '../widgets/sync_status_widget.dart';



class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: <Widget>[
          const _SyncActionButton(),
          IconButton(
            tooltip: 'Appearance',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ThemeScreen(),
              ),
            ),
          ),
        ],
      ),
      body: const Column(
        children: <Widget>[
          ConnectivityBanner(),
          SyncStatusWidget(),
          Expanded(child: PostList()),
        ],
      ),
    );
  }
}



class _SyncActionButton extends ConsumerWidget {
  const _SyncActionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSyncing = ref.watch(
      syncControllerProvider.select((SyncState s) => s.isSyncing),
    );

    return IconButton(
      tooltip: isSyncing ? 'Syncing…' : 'Sync now',
      onPressed: isSyncing
          ? null
          : () => ref.read(syncControllerProvider.notifier).syncNow(),
      icon: isSyncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
    );
  }
}
