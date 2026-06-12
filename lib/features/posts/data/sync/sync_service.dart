import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

/// Outcome of a synchronisation attempt.
class SyncResult {
  const SyncResult.success(this.posts) : error = null;
  const SyncResult.failure(this.error) : posts = const <Post>[];

  final List<Post> posts;
  final String? error;

  bool get isSuccess => error == null;
  int get count => posts.length;
}

class SyncService {
  SyncService(this._repository);

  final PostRepository _repository;

  Future<SyncResult> synchronize() async {
    try {
      final List<Post> posts = await _repository.refreshPosts();
      return SyncResult.success(posts);
    } catch (error) {
      return SyncResult.failure(error.toString());
    }
  }
}
