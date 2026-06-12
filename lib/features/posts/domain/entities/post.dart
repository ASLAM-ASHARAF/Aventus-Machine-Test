import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// Pure domain entity representing a single post.
///
/// It carries no serialization or persistence concerns — those live in the
/// data layer ([PostModel]). Using Freezed gives us value equality and a
/// `copyWith` for free.
@freezed
abstract class Post with _$Post {
  const factory Post({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _Post;
}
