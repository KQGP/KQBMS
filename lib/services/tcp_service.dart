import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'bms_transport.dart';
import 'frame_assembler.dart';

/// WiFi transport: connects to the KQBMS ESP32 bridge over TCP and tunnels
/// raw JBD frames 1:1, mirroring [BleService]'s stream API exactly.
class TcpService implements BmsTransport {
  static final TcpService _instance = TcpService._internal();
  factory TcpService() => _instance;
  TcpService._internal();

  Socket? _socket;
  StreamSubscription<Uint8List>? _socketSubscription;

  late final FrameAssembler _assembler = FrameAssembler(
    onPacket: (packet) => _dataController.add(packet),
  );

  String _host = '';
  int _port = 3333;

  /// mDNS type advertised by the bridge firmware (kqbms-bridge.local)
  static const String mdnsServiceType = '_kqbms._tcp.local';

  final _dataController = StreamController<List<int>>.broadcast();
  @override
  Stream<List<int>> get responseStream => _dataController.stream;

  final _authStatusController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get authStatusStream => _authStatusController.stream;

  final _disconnectController = StreamController<void>.broadcast();
  @override
  Stream<void> get disconnectStream => _disconnectController.stream;

  void configure({required String host, required int port}) {
    _host = host.trim();
    _port = port;
  }

  /// Searches the local network for the ESP32 bridge via mDNS.
  /// Returns its IP address and port, or null when not found.
  Future<MapEntry<String, int>?> discoverBridge({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (kIsWeb) return null;
    final client = MDnsClient();
    try {
      await client.start();
      await for (final ptr in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(mdnsServiceType),
        timeout: timeout,
      )) {
        await for (final srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
          timeout: timeout,
        )) {
          await for (final ip in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target),
            timeout: timeout,
          )) {
            return MapEntry(ip.address.address, srv.port);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      client.stop();
    }
  }

  /// Connects to the bridge. When the configured host is empty or a .local
  /// name, mDNS discovery is attempted first and used when it succeeds.
  Future<void> connect() async {
    if (kIsWeb) {
      throw UnsupportedError('WiFi connection is not supported on web');
    }

    await _cleanup(notifyDisconnect: false);
    _authStatusController.add(false);

    var host = _host;
    var port = _port;

    if (host.isEmpty || host.toLowerCase().endsWith('.local')) {
      final found = await discoverBridge();
      if (found != null) {
        host = found.key;
        port = found.value;
      }
    }
    if (host.isEmpty) {
      throw Exception('No bridge address configured');
    }

    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 8),
    );

    _socket = socket;
    _assembler.reset();

    _socketSubscription = socket.listen(
      (chunk) => _assembler.push(chunk),
      onError: (Object e) {
        _cleanup();
      },
      onDone: () {
        _cleanup();
      },
      cancelOnError: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    _authStatusController.add(true);
  }

  @override
  Future<void> write(List<int> data) async {
    final socket = _socket;
    if (socket == null) {
      throw Exception('Not connected to bridge');
    }
    socket.add(data);
    await socket.flush();
  }

  @override
  Future<void> disconnect() async {
    await _cleanup();
  }

  Future<void> _cleanup({bool notifyDisconnect = true}) async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    _socket?.destroy();
    _socket = null;
    _assembler.reset();
    if (notifyDisconnect) {
      _disconnectController.add(null);
    }
  }
}
