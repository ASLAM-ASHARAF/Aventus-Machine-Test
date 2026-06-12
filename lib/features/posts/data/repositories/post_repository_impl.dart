import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_data_source.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_model.dart';



class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required PostRemoteDataSource remote,
    required PostLocalDataSource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  final PostRemoteDataSource _remote;
  final PostLocalDataSource _local;
  final ConnectivityService _connectivity;

  @override
  Future<List<Post>> getPosts() async {
    if (await _connectivity.isOnline()) {
      try {
        return await refreshPosts();
      } catch (_) {
          return _cached();

      }
    }
    return _cached();
  }

  @override
  Future<List<Post>> refreshPosts() async {
    final List<PostModel> remote = await _remote.fetchPosts();
    await _local.cachePosts(remote);
    return remote.map((PostModel m) => m.toEntity()).toList(growable: false);
  }

  @override
  DateTime? get lastSyncTime => _local.lastSyncTime;

  List<Post> _cached() =>
      _local.getPosts().map((PostModel m) => m.toEntity()).toList(growable: false);
}
