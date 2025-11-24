import 'dart:io';

class NetworkChecker {
  /// Check if device has internet connectivity
  /// Returns true if connected, false otherwise
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Check connectivity with custom host
  static Future<bool> hasConnectionToHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Get connectivity status message
  static Future<String> getConnectivityStatus() async {
    final isConnected = await hasConnection();
    return isConnected ? 'Connected' : 'No internet connection';
  }
}
