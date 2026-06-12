import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_providers.dart';
import 'data/datasources/post_local_data_source.dart';
import 'data/datasources/post_remote_data_source.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/sync/sync_service.dart';
import 'domain/repositories/post_repository.dart';



final Provider<PostRemoteDataSource> postRemoteDataSourceProvider =
    Provider<PostRemoteDataSource>(
  (ref) => PostRemoteDataSource(ref.watch(dioProvider)),
);



final Provider<PostLocalDataSource> postLocalDataSourceProvider =
    Provider<PostLocalDataSource>(
  (ref) => PostLocalDataSource(
    postsBox: ref.watch(postsBoxProvider),
    settingsBox: ref.watch(settingsBoxProvider),
  ),
);

final Provider<PostRepository> postRepositoryProvider =
    Provider<PostRepository>(
  (ref) => PostRepositoryImpl(
    remote: ref.watch(postRemoteDataSourceProvider),
    local: ref.watch(postLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  ),
);

final Provider<SyncService> syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(postRepositoryProvider)),
);
