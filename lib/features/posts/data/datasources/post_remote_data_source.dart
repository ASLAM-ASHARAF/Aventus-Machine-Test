import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/post_model.dart';


class PostRemoteDataSource {
  PostRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PostModel>> fetchPosts() async {
    try {
      final Response<List<dynamic>> response =
          await _dio.get<List<dynamic>>(AppConstants.postsEndpoint);
      final List<dynamic> data = response.data ?? const <dynamic>[];
      return data
          .map((dynamic e) =>
              PostModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
