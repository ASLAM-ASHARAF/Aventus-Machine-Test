import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../posts_providers.dart';
import 'posts_controller.dart';

enum SyncStatus { idle, syncing, success, failure }



@immutable
class SyncState {
  const SyncState({
    required this.status,
    this.lastSyncAt,
    this.message,
  });

  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? message;

  bool get isSyncing => status == SyncStatus.syncing;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? message,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      message: message ?? this.message,
    );
  }
}



class SyncController extends Notifier<SyncState> {
  @override
  SyncState build() {
   
   
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (prev, next) {
      final bool wasOnline = prev?.value ?? false;
      final bool isOnline = next.value ?? false;
      final bool isFirstEmission = prev == null;
      if (isOnline && !wasOnline && !isFirstEmission) {
        _synchronize();
      }
    });

  
    final DateTime? last = ref.read(postRepositoryProvider).lastSyncTime;
    return SyncState(status: SyncStatus.idle, lastSyncAt: last);
  }

  Future<void> syncNow() => _synchronize();

  Future<void> _synchronize() async {
    if (state.isSyncing) return; 
    state = state.copyWith(status: SyncStatus.syncing, message: 'Syncing…');

    final result = await ref.read(syncServiceProvider).synchronize();


    if (result.isSuccess) {
     
      ref.read(postsControllerProvider.notifier).applySynced(result.posts);
      state = SyncState(
        status: SyncStatus.success,
      

        lastSyncAt: ref.read(postRepositoryProvider).lastSyncTime ?? DateTime.now(),
        message: 'Synced ${result.count} posts',
      );
      
    } else {
      state = state.copyWith(
        status: SyncStatus.failure,
        message: result.error,
      );
    }
  }
}

final NotifierProvider<SyncController, SyncState> syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);

/// The three states surfaced by the status banner.
enum BannerStatus { online, offline, syncing }

/// Derives the banner status from connectivity + sync activity. Kept tiny and
/// `select`-driven so the banner rebuilds only when this derived value flips.
final Provider<BannerStatus> bannerStatusProvider = Provider<BannerStatus>((ref) {
  final bool online =
      ref.watch(connectivityStatusProvider).value ?? true;
  final bool syncing =
      ref.watch(syncControllerProvider.select((SyncState s) => s.isSyncing));
  if (syncing) return BannerStatus.syncing;
  return online ? BannerStatus.online : BannerStatus.offline;
});
