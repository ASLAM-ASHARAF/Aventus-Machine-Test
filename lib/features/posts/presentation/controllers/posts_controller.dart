import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../../posts_providers.dart';


class PostsController extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => ref.watch(postRepositoryProvider).getPosts();

   
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getPosts(),
    );
  }

  void applySynced(List<Post> posts) =>
      state = AsyncValue<List<Post>>.data(posts);
}

final AsyncNotifierProvider<PostsController, List<Post>> postsControllerProvider =
    AsyncNotifierProvider<PostsController, List<Post>>(PostsController.new);
