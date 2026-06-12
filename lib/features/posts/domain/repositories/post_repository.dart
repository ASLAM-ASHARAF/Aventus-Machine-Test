import '../entities/post.dart';


abstract interface class PostRepository {

  Future<List<Post>> getPosts();

  Future<List<Post>> refreshPosts();

 

  DateTime? get lastSyncTime;
}
