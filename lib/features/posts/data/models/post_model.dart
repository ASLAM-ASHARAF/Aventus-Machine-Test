import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/post.dart';

part 'post_model.g.dart';

/// Data-layer representation of a post.
///
/// Responsibilities:
///  * JSON (de)serialization for the remote API (`json_serializable`).
///  * Local persistence in Hive — a `TypeAdapter` is generated for this class
///    via the `@GenerateAdapters` annotation in `core/hive/hive_adapters.dart`,
///    so the model itself stays free of Hive annotations.
///  * Mapping to/from the pure [Post] domain entity.
@immutable
@JsonSerializable()
class PostModel {
  const PostModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  factory PostModel.fromEntity(Post post) => PostModel(
        userId: post.userId,
        id: post.id,
        title: post.title,
        body: post.body,
      );

  Post toEntity() => Post(
        id: id,
        userId: userId,
        title: title,
        body: body,
      );
}
