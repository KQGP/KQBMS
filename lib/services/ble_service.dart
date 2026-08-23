import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bms_transport.dart';
import 'frame_assembler.dart';

class BleService implements BmsTransport {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription? _notificationSubscription;

  late final FrameAssembler _assembler = FrameAssembler(
    onPacket: (packet) => _dataController.add(packet),
  );

  final String serviceUuid = "0000ff00-0000-1000-8000-00805f9b34fb";
  final String rxCharUuid = "0000ff01-0000-1000-8000-00805f9b34fb";
  final String txCharUuid = "0000ff02-0000-1000-8000-00805f9b34fb";

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  final _dataController = StreamController<List<int>>.broadcast();
  @override
  Stream<List<int>> get responseStream => _dataController.stream;

  final _authStatusController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get authStatusStream => _authStatusController.stream;

  final _disconnectController = StreamController<void>.broadcast();
  @override
  Stream<void> get disconnectStream => _disconnectController.stream;

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    final scanStatus = await Permission.bluetoothScan.status;
    final connectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.location.status;

    if (scanStatus.isGranted && connectStatus.isGranted) {
      return true;
    }

    List<Permission> toRequest = [];
    
    if (scanStatus.isDenied) toRequest.add(Permission.bluetoothScan);
    if (connectStatus.isDenied) toRequest.add(Permission.bluetoothConnect);
    
    if (toRequest.isEmpty && locationStatus.isDenied) {
      toRequest.add(Permission.location);
    }

    if (toRequest.isEmpty) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await toRequest.request();

    return statuses.values.every((status) => status.isGranted || status.isLimited);
  }

  Future<void> ensureBluetoothOn() async {
    if (kIsWeb) return;
    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (state == BluetoothAdapterState.on) return;

      await FlutterBluePlus.turnOn();

      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      return;
    }
  }

  Future<void> startScan() async {
    if (!kIsWeb) {
      final scanStatus = await Permission.bluetoothScan.status;
      final connectStatus = await Permission.bluetoothConnect.status;
      if (!scanStatus.isGranted || !connectStatus.isGranted) {
        final granted = await requestPermissions();
        if (!granted) return;
      }

      await ensureBluetoothOn();

      await FlutterBluePlus.adapterState
          .where((s) => s != BluetoothAdapterState.unknown)
          .first
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => BluetoothAdapterState.on,
          );
    }

    await FlutterBluePlus.startScan(
      withServices: [Guid(serviceUuid)],
      timeout: const Duration(seconds: 10),
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    _connectedDevice = device;
    _authStatusController.add(false);

    await device.connect(license: License.nonprofit, autoConnect: false);

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().toLowerCase().contains("ff00")) {
        for (var c in service.characteristics) {
          final uuid = c.uuid.toString().toLowerCase();
          if (uuid.contains("ff01")) {
            if (c.properties.write || c.properties.writeWithoutResponse) {
              _txCharacteristic = c;
            }
            if (c.properties.notify) {
              _rxCharacteristic = c;
              await c.setNotifyValue(true);
            }
          } else if (uuid.contains("ff02")) {
            if (c.properties.write || c.properties.writeWithoutResponse) {
              _txCharacteristic = c;
            }
            if (c.properties.notify) {
              _rxCharacteristic = c;
              await c.setNotifyValue(true);
            }
          }
        }
      }
    }

    if (_rxCharacteristic == null || _txCharacteristic == null) {
      throw Exception("Required characteristics not found");
    }

    _notificationSubscription =
        _rxCharacteristic!.onValueReceived.listen(_assembler.push);

    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _disconnectController.add(null);
      }
    });

    await Future.delayed(const Duration(milliseconds: 300));

    _authStatusController.add(true);
  }

  @override
  Future<void> disconnect() async {
    await _notificationSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _assembler.reset();
    _disconnectController.add(null);
  }

  @override
  Future<void> write(List<int> data) async {
    if (_txCharacteristic == null) {
      throw Exception("TX characteristic is null");
    }

    await _txCharacteristic!.write(data, withoutResponse: true);
  }
}
