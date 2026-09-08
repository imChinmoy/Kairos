import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.isNotEmpty && !results.contains(ConnectivityResult.none),
  );
});

class ConnectivityService {
  static Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
