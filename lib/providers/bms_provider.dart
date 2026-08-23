import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/bms_data.dart';
import '../protocol/bms_protocol.dart';
import '../services/ble_service.dart';
import '../services/bms_transport.dart';
import '../services/tcp_service.dart';
import 'settings_provider.dart';

class BmsProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final TcpService _tcpService = TcpService();
  SettingsProvider? _settingsProvider;

  bool _useWifi = false;

  BmsTransport get _transport => _useWifi ? _tcpService : _bleService;

  String get transportMode => _useWifi ? 'wifi' : 'ble';

  String get deviceName {
    if (_useWifi) {
      final host = _settingsProvider?.wifiHost;
      return (host == null || host.isEmpty)
          ? SettingsProvider.defaultWifiHost
          : host;
    }
    return _device?.platformName ?? "BMS";
  }

  void updateSettings(SettingsProvider settings) {
    final previousInterval = _settingsProvider?.refreshIntervalMs;
    _settingsProvider = settings;
    if (previousInterval != null &&
        settings.refreshIntervalMs != previousInterval) {
      _restartPollingTimer();
    }
  }

  BluetoothDevice? _device;
  BmsBaseInfo? _baseInfo;
  BmsCellVoltages? _cellVoltages;
  BmsHardwareVersion? _hardwareVersion;
  BmsDeviceInfo _deviceInfo = BmsDeviceInfo();
  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  Timer? _pollingTimer;
  Timer? _wifiReconnectTimer;
  int _wifiReconnectAttempts = 0;
  static const int _maxWifiReconnectAttempts = 5;
  StreamSubscription? _responseSubscription;
  StreamSubscription? _authSubscription;
  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _isScanningSubscription;
  StreamSubscription? _disconnectSubscription;
  int? _pendingExtOffset;

  BluetoothDevice? get device => _device;
  BmsBaseInfo? get baseInfo => _baseInfo;
  BmsCellVoltages? get cellVoltages => _cellVoltages;
  BmsHardwareVersion? get hardwareVersion => _hardwareVersion;
  BmsDeviceInfo get deviceInfo => _deviceInfo;
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  bool get isConnecting => _isConnected && !_isAuthenticated;

  bool get hasMalfunctions {
    if (_baseInfo != null && _baseInfo!.activeProtections.isNotEmpty) {
      return true;
    }
    if (_baseInfo != null && _baseInfo!.temperatureAlarms.isNotEmpty) {
      return true;
    }
    if (_cellVoltages != null && _cellVoltages!.cellAlarms.isNotEmpty) {
      return true;
    }
    return false;
  }

  List<BmsMalfunction> get activeMalfunctions {
    final issues = <BmsMalfunction>[];
    final info = _baseInfo;
    if (info != null) {
      issues.addAll(info.activeProtections);
      issues.addAll(info.temperatureAlarms);
    }
    if (_cellVoltages != null) {
      issues.addAll(_cellVoltages!.cellAlarms);
    }
    return issues;
  }

  Future<void> initializeBluetooth() async {
    await _bleService.requestPermissions();
    await _bleService.ensureBluetoothOn();
  }

  Future<void> enableBluetooth() => _bleService.ensureBluetoothOn();

  Future<bool> autoConnect(String deviceId) async {
    if (kIsWeb) return false;
    if (_settingsProvider?.transportMode == 'wifi') {
      try {
        await connectToWifi();
        for (int i = 0; i < 20 && !_isAuthenticated; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        return _isConnected && _isAuthenticated;
      } catch (e) {
        return false;
      }
    }
    try {
      await _bleService.ensureBluetoothOn();
      
      _bleService.startScan();
      
      Completer<BluetoothDevice?> completer = Completer();
      StreamSubscription? sub;
      
      sub = _bleService.scanResults.listen((results) {
        for (var r in results) {
          if (r.device.remoteId.toString() == deviceId) {
            sub?.cancel();
            _bleService.stopScan();
            completer.complete(r.device);
            return;
          }
        }
      });
      
      final device = await completer.future.timeout(const Duration(seconds: 4), onTimeout: () {
        sub?.cancel();
        _bleService.stopScan();
        return null;
      });
      
      if (device != null) {
        await connectToDevice(device);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> startScan() async {
    _isScanning = true;
    _scanResults = [];
    notifyListeners();

    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();

    _scanResultsSubscription = _bleService.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    _isScanningSubscription = _bleService.isScanning.listen((scanning) {
      _isScanning = scanning;
      notifyListeners();
    });

    await _bleService.startScan();
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await _bleService.stopScan();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _isScanning = false;
    try {
      _device = device;
      _isConnected = true;
      _isAuthenticated = false;
      _chargeEnabled = false;
      _dischargeEnabled = false;
      _toggleStateInitialized = false;
      _lastMosWriteAt = null;

      _startListening();
      _startAuthListening();
      _startDisconnectListener();

      await _bleService.connect(device);

      _settingsProvider?.setLastDeviceId(device.remoteId.toString());

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> connectToWifi({String? host, int? port}) async {
    _useWifi = true;
    _device = null;
    _isConnected = true;
    _isAuthenticated = false;
    _chargeEnabled = false;
    _dischargeEnabled = false;
    _toggleStateInitialized = false;
    _lastMosWriteAt = null;

    _startListening();
    _startAuthListening();
    _startDisconnectListener();

    try {
      final resolvedHost = (host != null && host.trim().isNotEmpty)
          ? host.trim()
          : (_settingsProvider?.wifiHost ?? SettingsProvider.defaultWifiHost);
      final resolvedPort =
          port ?? _settingsProvider?.wifiPort ?? SettingsProvider.defaultWifiPort;

      _tcpService.configure(host: resolvedHost, port: resolvedPort);
      await _tcpService.connect();
      _wifiReconnectAttempts = 0;

      await _settingsProvider?.setWifiHost(resolvedHost);
      await _settingsProvider?.setWifiPort(resolvedPort);
      await _settingsProvider?.setTransportMode('wifi');

      notifyListeners();
    } catch (e) {
      await _tcpService.disconnect().catchError((_) {});
      _isConnected = false;
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<MapEntry<String, int>?> discoverBridge() =>
      _tcpService.discoverBridge();

  Future<void> disconnect() async {
    _stopPolling();
    _wifiReconnectTimer?.cancel();
    _wifiReconnectTimer = null;
    _wifiReconnectAttempts = 0;
    await _responseSubscription?.cancel();
    await _authSubscription?.cancel();
    await _scanResultsSubscription?.cancel();
    await _isScanningSubscription?.cancel();
    await _disconnectSubscription?.cancel();
    await _transport.disconnect();
    _device = null;
    _isConnected = false;
    _isAuthenticated = false;
    _baseInfo = null;
    _cellVoltages = null;
    _hardwareVersion = null;
    _deviceInfo = BmsDeviceInfo();
    _chargeEnabled = false;
    _dischargeEnabled = false;
    _toggleStateInitialized = false;
    _lastMosWriteAt = null;
    notifyListeners();
  }

  void _startListening() {
    _responseSubscription?.cancel();
    _responseSubscription = _transport.responseStream.listen((data) {
      try {
        final packet = BmsProtocol.parseResponse(data);
        final cmd = packet['command'];
        final status = packet['status'] as int? ?? 0;
        final payload = packet['data'] as List<int>;

        if (cmd == BmsProtocol.CMD_READ_BASE_INFO) {
          _baseInfo = BmsBaseInfo.fromBytes(payload);
          _syncToggleStateFromDevice();
        } else if (cmd == BmsProtocol.CMD_MOS_CONTROL) {
          _handleMosWriteAck(status);
        } else if (cmd == BmsProtocol.CMD_READ_CELL_VOLTAGES) {
          _cellVoltages = BmsCellVoltages.fromBytes(payload);
        } else if (cmd == BmsProtocol.CMD_READ_HARDWARE_VERSION) {
          _hardwareVersion = BmsHardwareVersion.fromBytes(payload);
        } else if (cmd == BmsProtocol.CMD_SERIAL_NUMBER) {
          _deviceInfo = _deviceInfo.copyWith(
            serialNumber: BmsDeviceInfo.fromSerialBytes(payload).serialNumber,
          );
        } else if (cmd == BmsProtocol.CMD_BARCODE) {
          _deviceInfo = _deviceInfo.copyWith(
            barcode: BmsDeviceInfo.fromBarcodeBytes(payload).barcode,
          );
        } else if (cmd == BmsProtocol.CMD_MANUFACTURER) {
          _deviceInfo = _deviceInfo.copyWith(
            manufacturer: BmsDeviceInfo.fromManufacturerBytes(payload).manufacturer,
          );
        } else if (cmd == BmsProtocol.CMD_BATTERY_MODEL) {
          _deviceInfo = _deviceInfo.copyWith(
            batteryModel: BmsDeviceInfo.fromBatteryModelBytes(payload).batteryModel,
          );
        } else if (cmd == BmsProtocol.CMD_EXTENDED_PARAMS) {
          final offset = _pendingExtOffset;
          _pendingExtOffset = null;
          if (offset != null) {
            if (offset == 117 && payload.length >= 8) {
              _deviceInfo = _deviceInfo.copyWith(
                ratedDischargeCurrent: ((payload[2] << 8) | payload[3]) / 100.0,
                ratedChargeCurrent: ((payload[4] << 8) | payload[5]) / 100.0,
                ratedDischargePower: ((payload[6] << 8) | payload[7]) / 100.0,
              );
            } else if (offset == 170 && payload.length >= 4) {
              String addr = payload
                  .take(4)
                  .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                  .join(':');
              _deviceInfo = _deviceInfo.copyWith(bmsAddress: addr);
            } else if (offset == 176) {
              String model = String.fromCharCodes(
                payload.where((b) => b >= 0x20 && b <= 0x7E).toList(),
              );
              if (model.isNotEmpty) {
                _deviceInfo = _deviceInfo.copyWith(bmsModel: model);
              }
            }
          }
        }
        notifyListeners();
      } catch (_) {
        return;
      }
    });
  }

  void _startAuthListening() {
    _authSubscription?.cancel();
    _authSubscription = _transport.authStatusStream.listen((isAuth) {
      _isAuthenticated = isAuth;
      if (isAuth) {
        _startPolling();
      }
      notifyListeners();
    });
  }

  bool _pollBusy = false;

  void _startPolling() {
    _pendingExtOffset = null;

    unawaited(_requestInitialData());

    unawaited(Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isConnected && _isAuthenticated) {
        _requestDeviceInfo();
      }
    }));

    _restartPollingTimer();
  }

  void _restartPollingTimer() {
    if (!_isConnected || !_isAuthenticated) return;
    final intervalMs = _settingsProvider?.refreshIntervalMs ?? 5000;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      unawaited(_pollTick());
    });
  }

  Future<void> _pollTick() async {
    if (_pollBusy) return;
    _pollBusy = true;
    try {
      await _requestInitialData();
    } finally {
      _pollBusy = false;
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _startDisconnectListener() {
    _disconnectSubscription?.cancel();
    _disconnectSubscription = _transport.disconnectStream.listen((_) {
      if (_isConnected) {
        _isConnected = false;
        _isAuthenticated = false;
        notifyListeners();
        _scheduleWifiReconnect();
      }
    });
  }

  void _scheduleWifiReconnect() {
    if (!_useWifi) return;
    if (!(_settingsProvider?.autoReconnect ?? false)) return;
    if (_wifiReconnectTimer != null) return;
    if (_wifiReconnectAttempts >= _maxWifiReconnectAttempts) return;

    final delay = Duration(seconds: 2 * (_wifiReconnectAttempts + 1));
    _wifiReconnectAttempts++;
    _wifiReconnectTimer = Timer(delay, () async {
      _wifiReconnectTimer = null;
      if (_isConnected || !_useWifi) return;
      try {
        await connectToWifi();
        _wifiReconnectAttempts = 0;
      } catch (_) {
        _scheduleWifiReconnect();
      }
    });
  }

  Future<void> _requestInitialData() async {
    try {
      await _transport.write(BmsProtocol.createReadPacket(
        BmsProtocol.CMD_READ_BASE_INFO,
      ));
      await Future.delayed(const Duration(milliseconds: 150));

      await _transport.write(BmsProtocol.createReadPacket(
        BmsProtocol.CMD_READ_CELL_VOLTAGES,
      ));
      await Future.delayed(const Duration(milliseconds: 150));

      await _transport.write(BmsProtocol.createReadPacket(
        BmsProtocol.CMD_READ_HARDWARE_VERSION,
      ));
    } catch (_) {
      return;
    }
  }

  Future<void> _requestDeviceInfo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await _transport.write(BmsProtocol.createFactoryModeOpenPacket());
      await Future.delayed(const Duration(milliseconds: 100));

      _pendingExtOffset = 117;
      await _transport.write(BmsProtocol.createExtendedReadPacket(117, 8));
      await Future.delayed(const Duration(milliseconds: 100));

      _pendingExtOffset = 170;
      await _transport.write(BmsProtocol.createExtendedReadPacket(170, 6));
      await Future.delayed(const Duration(milliseconds: 100));

      _pendingExtOffset = 176;
      await _transport.write(BmsProtocol.createExtendedReadPacket(176, 8));
      await Future.delayed(const Duration(milliseconds: 100));

      await _transport.write(
        BmsProtocol.createReadPacket(BmsProtocol.CMD_SERIAL_NUMBER),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _transport.write(
        BmsProtocol.createReadPacket(BmsProtocol.CMD_BARCODE),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _transport.write(
        BmsProtocol.createReadPacket(BmsProtocol.CMD_MANUFACTURER),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _transport.write(
        BmsProtocol.createReadPacket(BmsProtocol.CMD_BATTERY_MODEL),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _transport.write(BmsProtocol.createFactoryModeClosePacket());
    } catch (_) {
      return;
    }
  }

  bool _chargeEnabled = false;
  bool _dischargeEnabled = false;
  bool _toggleStateInitialized = false;
  DateTime? _lastMosWriteAt;

  static const Duration _mosSyncCooldown = Duration(milliseconds: 1500);

  bool get isChargeEnabled =>
      _toggleStateInitialized ? _chargeEnabled : (_baseInfo?.isCharging ?? false);

  bool get isDischargeEnabled => _toggleStateInitialized
      ? _dischargeEnabled
      : (_baseInfo?.isDischarging ?? false);

  Future<void> enableCharge(bool on) async {
    final info = _baseInfo;
    if (info == null) return;
    final previous = _chargeEnabled;
    _chargeEnabled = on;
    _lastMosWriteAt = DateTime.now();
    notifyListeners();
    try {
      await _writeMosState();
      await _confirmMosState();
    } catch (_) {
      _chargeEnabled = previous;
      notifyListeners();
    }
  }

  Future<void> enableDischarge(bool on) async {
    final info = _baseInfo;
    if (info == null) return;
    final previous = _dischargeEnabled;
    _dischargeEnabled = on;
    _lastMosWriteAt = DateTime.now();
    notifyListeners();
    try {
      await _writeMosState();
      await _confirmMosState();
    } catch (_) {
      _dischargeEnabled = previous;
      notifyListeners();
    }
  }

  Future<void> _writeMosState() async {
    final ctrl = BmsProtocol.mosControlValue(
      chargeEnabled: _chargeEnabled,
      dischargeEnabled: _dischargeEnabled,
    );
    await sendMosControl(ctrl);
  }

  Future<void> _confirmMosState() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await requestBaseInfo();
    } catch (_) {}
  }

  void _handleMosWriteAck(int status) {
    if (status == 0x00) return;
    final info = _baseInfo;
    if (info != null) {
      _chargeEnabled = info.isCharging;
      _dischargeEnabled = info.isDischarging;
      notifyListeners();
    }
  }

  void _syncToggleStateFromDevice() {
    final info = _baseInfo;
    if (info == null) return;
    final lastWrite = _lastMosWriteAt;
    if (lastWrite != null &&
        DateTime.now().difference(lastWrite) < _mosSyncCooldown) {
      return;
    }
    _chargeEnabled = info.isCharging;
    _dischargeEnabled = info.isDischarging;
    _toggleStateInitialized = true;
  }

  Future<void> sendMosControl(int controlValue) async {
    try {
      final mosPacket = BmsProtocol.createMosControlPacket(controlValue);
      await _transport.write(mosPacket);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestBaseInfo() async {
    try {
      final packet = BmsProtocol.createReadPacket(
        BmsProtocol.CMD_READ_BASE_INFO,
      );
      await _transport.write(packet);
    } catch (e) {
      rethrow;
    }
  }
}
