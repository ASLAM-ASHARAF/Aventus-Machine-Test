import 'package:aventus_machine_test/features/posts/data/models/post_model.dart';
import 'package:aventus_machine_test/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostModel', () {
    const Map<String, dynamic> json = <String, dynamic>{
      'userId': 1,
      'id': 42,
      'title': 'hello',
      'body': 'world',
    };

    test('deserializes from API JSON', () {
      final PostModel model = PostModel.fromJson(json);
      expect(model.userId, 1);
      expect(model.id, 42);
      expect(model.title, 'hello');
      expect(model.body, 'world');
    });

    test('round-trips through JSON', () {
      final PostModel model = PostModel.fromJson(json);
      expect(model.toJson(), json);
    });

    test('maps to and from the domain entity', () {
      final Post entity = PostModel.fromJson(json).toEntity();
      expect(entity, const Post(id: 42, userId: 1, title: 'hello', body: 'world'));

      final PostModel back = PostModel.fromEntity(entity);
      expect(back.toJson(), json);
    });
  });
}
