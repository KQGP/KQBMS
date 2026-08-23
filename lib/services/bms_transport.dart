import 'dart:async';

/// Transport-agnostic connection to a JBD BMS.
///
/// Implemented by [BleService] (direct Bluetooth) and [TcpService]
/// (WiFi via ESP32 bridge). Both deliver identical raw JBD frames.
abstract class BmsTransport {
  Future<void> disconnect();

  Future<void> write(List<int> data);

  Stream<List<int>> get responseStream;

  Stream<bool> get authStatusStream;

  Stream<void> get disconnectStream;
}
