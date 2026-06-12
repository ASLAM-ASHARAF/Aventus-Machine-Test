import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../controllers/posts_controller.dart';
import 'post_tile.dart';



class PostList extends ConsumerWidget {

  const PostList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Post>> postsAsync =
        ref.watch(postsControllerProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => _ErrorView(message: error.toString()),
      data: (List<Post> posts) {
        if (posts.isEmpty) return const _EmptyView();
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(postsControllerProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) =>
                PostTile(post: posts[index]),
          ),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(

      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        const Center(child: Text('No posts cached yet.')),
        const SizedBox(height: 8),
        const Center(
          child: Text('Connect to the internet and sync to load posts.'),
        ),
      ],
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(postsControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
