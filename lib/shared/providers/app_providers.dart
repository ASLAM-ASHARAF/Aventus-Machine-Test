import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/connectivity_service.dart';
import '../../features/posts/data/models/post_model.dart';



final Provider<Box> settingsBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'settingsBoxProvider must be overridden in main()',
  ),
);


final Provider<Box<PostModel>> postsBoxProvider = Provider<Box<PostModel>>(
  (ref) => throw UnimplementedError(
    'postsBoxProvider must be overridden in main()',
  ),
);


final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final Dio dio = DioClient.create();
  ref.onDispose(dio.close);
  return dio;
});


final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>(
  (ref) => ConnectivityService(Connectivity()),
);



final StreamProvider<bool> connectivityStatusProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).watch(),
);
