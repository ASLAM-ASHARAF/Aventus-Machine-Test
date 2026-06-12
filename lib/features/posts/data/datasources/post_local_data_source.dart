import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/post_model.dart';



class PostLocalDataSource {
  PostLocalDataSource({
    required Box<PostModel> postsBox,
    required Box settingsBox,
  })  : _postsBox = postsBox,
        _settingsBox = settingsBox;

  final Box<PostModel> _postsBox;
  final Box _settingsBox;

  List<PostModel> getPosts() =>
      _postsBox.values.toList(growable: false);

  bool get hasCache => _postsBox.isNotEmpty;



  Future<void> cachePosts(List<PostModel> posts) async {
    final Map<int, PostModel> fresh = <int, PostModel>{
      for (final PostModel post in posts) post.id: post,
    };
    await _postsBox.putAll(fresh);

    final List<int> stale = _postsBox.keys
        .cast<int>()
        .where((int key) => !fresh.containsKey(key))
        .toList(growable: false);
    if (stale.isNotEmpty) await _postsBox.deleteAll(stale);

    await _settingsBox.put(
      AppConstants.lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? get lastSyncTime {
    final String? raw = _settingsBox.get(AppConstants.lastSyncKey) as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
