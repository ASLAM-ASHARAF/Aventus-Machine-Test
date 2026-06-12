import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());


  Stream<bool> watch() async* {
    yield await isOnline();
    yield* _connectivity.onConnectivityChanged.map(_isOnline);
  }
}
