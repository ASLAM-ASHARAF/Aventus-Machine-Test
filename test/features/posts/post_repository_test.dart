import 'package:aventus_machine_test/core/services/connectivity_service.dart';
import 'package:aventus_machine_test/features/posts/data/datasources/post_local_data_source.dart';
import 'package:aventus_machine_test/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:aventus_machine_test/features/posts/data/models/post_model.dart';
import 'package:aventus_machine_test/features/posts/data/repositories/post_repository_impl.dart';
import 'package:aventus_machine_test/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

const PostModel _remotePost =
    PostModel(userId: 1, id: 1, title: 'remote', body: 'fresh');
const PostModel _cachedPost =
    PostModel(userId: 9, id: 9, title: 'cached', body: 'stale');



class _FakeRemote implements PostRemoteDataSource {
  _FakeRemote({this.shouldThrow = false});
  bool shouldThrow;
  int calls = 0;

  @override
  Future<List<PostModel>> fetchPosts() async {
    calls++;
    if (shouldThrow) throw Exception('network down');
    return <PostModel>[_remotePost];
  }
}

class _FakeLocal implements PostLocalDataSource {
  List<PostModel> _store = <PostModel>[_cachedPost];

  @override
  bool get hasCache => _store.isNotEmpty;

  @override
  List<PostModel> getPosts() => _store;

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    _store = List<PostModel>.from(posts);
  }

  @override
  DateTime? get lastSyncTime => null;
}

class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity(this._online);
  final bool _online;

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> watch() => Stream<bool>.value(_online);
}

PostRepositoryImpl _build({required bool online, bool remoteThrows = false}) {
  return PostRepositoryImpl(
    remote: _FakeRemote(shouldThrow: remoteThrows),
    local: _FakeLocal(),
    connectivity: _FakeConnectivity(online),
  );
}

void main() {
  group('PostRepositoryImpl (offline-first)', () {
    test('online: fetches fresh data and caches it', () async {
      final PostRepositoryImpl repo = _build(online: true);
      final List<Post> posts = await repo.getPosts();
      expect(posts.single.title, 'remote');
    });

    test('offline: returns the cached snapshot without hitting the network',
        () async {
      final _FakeRemote remote = _FakeRemote();
      final repo = PostRepositoryImpl(
        remote: remote,
        local: _FakeLocal(),
        connectivity: _FakeConnectivity(false),
      );
      final List<Post> posts = await repo.getPosts();
      expect(posts.single.title, 'cached');
      expect(remote.calls, 0); // never called while offline
    });

    test('online but request fails: degrades gracefully to cache', () async {
      final PostRepositoryImpl repo =
          _build(online: true, remoteThrows: true);
      final List<Post> posts = await repo.getPosts();
      expect(posts.single.title, 'cached');
    });

    test('refreshPosts rethrows on failure', () async {
      final PostRepositoryImpl repo =
          _build(online: true, remoteThrows: true);
      expect(repo.refreshPosts(), throwsException);
    });
  });
}
