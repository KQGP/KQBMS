class BmsMalfunction {
  final String token;
  final String? source;
  final String? value;
  final String? unit;

  BmsMalfunction({required this.token, this.source, this.value, this.unit});

  @override
  String toString() => '$token ($source: $value $unit)';
}

class BmsBaseInfo {
  static const List<String> protectionLabels = [
    "cellOvp", "cellUvp", "packOvp", "packUvp",
    "chargeOtp", "chargeUtp", "dischOtp", "dischUtp",
    "chargeOcp", "dischOcp", "shortCkt", "icError", "mosLock",
  ];

  static const double tempAlarmThreshold = 60.0;
  static const double cellLowThreshold = 3.0;
  static const double cellHighThreshold = 4.15;

  final double totalVoltage;
  final double current;
  final double remainingCapacity;
  final double nominalCapacity;
  final int cycleCount;
  final int rsoc;
  final List<double> temperatures;
  final bool isCharging;
  final bool isDischarging;
  final int protectionState;
  final String softwareVersion;
  final int cellCount;
  final int ntcCount;
  final String productionDate;
  final int balanceLow;
  final int balanceHigh;
  final double? learnCapacity;
  final double? balanceCurrent;
  final bool hasExtended;

  BmsBaseInfo({
    required this.totalVoltage,
    required this.current,
    required this.remainingCapacity,
    required this.nominalCapacity,
    required this.cycleCount,
    required this.rsoc,
    required this.temperatures,
    required this.isCharging,
    required this.isDischarging,
    required this.protectionState,
    required this.softwareVersion,
    required this.cellCount,
    required this.ntcCount,
    this.productionDate = '',
    this.balanceLow = 0,
    this.balanceHigh = 0,
    this.learnCapacity,
    this.balanceCurrent,
    this.hasExtended = false,
  });

  List<bool> get balanceBits {
    final bits = <bool>[];
    for (int i = 0; i < 16; i++) {
      bits.add(((balanceLow >> i) & 0x01) == 1);
    }
    for (int i = 0; i < 16; i++) {
      bits.add(((balanceHigh >> i) & 0x01) == 1);
    }
    return bits;
  }

  List<int> get balancingCells {
    final cells = <int>[];
    final bits = balanceBits;
    for (int i = 0; i < bits.length && i < cellCount; i++) {
      if (bits[i]) cells.add(i + 1);
    }
    return cells;
  }

  List<BmsMalfunction> get activeProtections {
    final labels = <BmsMalfunction>[];
    for (int i = 0; i < protectionLabels.length; i++) {
      if ((protectionState >> i) & 0x01 == 1) {
        labels.add(BmsMalfunction(token: protectionLabels[i]));
      }
    }
    return labels;
  }

  List<BmsMalfunction> get temperatureAlarms {
    final alarms = <BmsMalfunction>[];
    for (int i = 0; i < temperatures.length; i++) {
      final label = i == 0 ? "MOS" : "NTC$i";
      final temp = temperatures[i];
      if (temp > tempAlarmThreshold) {
        alarms.add(BmsMalfunction(
          source: label,
          value: temp.toStringAsFixed(1),
          unit: "°C",
          token: "overTemperature",
        ));
      } else if (temp < -20) {
        alarms.add(BmsMalfunction(
          source: label,
          value: temp.toStringAsFixed(1),
          unit: "°C",
          token: "sensorFault",
        ));
      }
    }
    return alarms;
  }

  factory BmsBaseInfo.fromBytes(List<int> data) {
    int voltageRaw = (data[0] << 8) | data[1];
    double totalVoltage = voltageRaw / 100.0;

    int currentRaw = (data[2] << 8) | data[3];
    if (currentRaw >= 0x8000) currentRaw -= 0x10000;
    double current = currentRaw / 100.0;

    int remainingCapRaw = (data[4] << 8) | data[5];
    double remainingCapacity = remainingCapRaw / 100.0;

    int nominalCapRaw = (data[6] << 8) | data[7];
    double nominalCapacity = nominalCapRaw / 100.0;

    int cycleCount = (data[8] << 8) | data[9];

    int prodDateRaw = (data[10] << 8) | data[11];
    int day = prodDateRaw & 0x1F;
    int month = (prodDateRaw >> 5) & 0x0F;
    int year = 2000 + (prodDateRaw >> 9);
    String productionDate = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    int balanceLow = (data[12] << 8) | data[13];
    int balanceHigh = (data[14] << 8) | data[15];
    int protectionState = (data[16] << 8) | data[17];

    int softwareVersionRaw = data[18];
    String softwareVersion =
        'v${(softwareVersionRaw >> 4).toString()}.${(softwareVersionRaw & 0x0F).toString()}';

    int rsoc = data[19];

    int mosStatus = data[20];
    bool isCharging = (mosStatus & 0x01) != 0;
    bool isDischarging = (mosStatus & 0x02) != 0;

    int cellCount = data[21];
    int ntcCount = data[22];

    List<double> temperatures = [];
    for (int i = 0; i < ntcCount; i++) {
      int tempIdx = 23 + (i * 2);
      if (tempIdx + 1 < data.length) {
        int tempRaw = (data[tempIdx] << 8) | data[tempIdx + 1];
        double tempCelsius = (tempRaw - 2731) * 0.1;
        temperatures.add(tempCelsius);
      }
    }

    int ntcEnd = 23 + (ntcCount * 2);
    double? learnCapacity;
    double? balanceCurrent;
    bool hasExtended = false;

    if (ntcEnd + 1 < data.length) {
      int extensionMarker = data[ntcEnd];
      hasExtended = extensionMarker == 136;
      if (hasExtended && ntcEnd + 5 < data.length) {
        int learnRaw = (data[ntcEnd + 3] << 8) | data[ntcEnd + 4];
        learnCapacity = learnRaw / 100.0;
        if (ntcEnd + 7 < data.length) {
          int balCurRaw = (data[ntcEnd + 5] << 8) | data[ntcEnd + 6];
          balanceCurrent = balCurRaw / 100.0;
        }
      }
    }

    return BmsBaseInfo(
      totalVoltage: totalVoltage,
      current: current,
      remainingCapacity: remainingCapacity,
      nominalCapacity: nominalCapacity,
      cycleCount: cycleCount,
      rsoc: rsoc,
      temperatures: temperatures,
      isCharging: isCharging,
      isDischarging: isDischarging,
      protectionState: protectionState,
      softwareVersion: softwareVersion,
      cellCount: cellCount,
      ntcCount: ntcCount,
      productionDate: productionDate,
      balanceLow: balanceLow,
      balanceHigh: balanceHigh,
      learnCapacity: learnCapacity,
      balanceCurrent: balanceCurrent,
      hasExtended: hasExtended,
    );
  }
}

class BmsCellVoltages {
  final List<double> voltages;

  BmsCellVoltages({required this.voltages});

  List<BmsMalfunction> get cellAlarms {
    final alarms = <BmsMalfunction>[];
    for (int i = 0; i < voltages.length; i++) {
      final v = voltages[i];
      if (v <= 0) {
        alarms.add(BmsMalfunction(
          source: "Cell #${i + 1}",
          token: "noReading",
        ));
      } else if (v < BmsBaseInfo.cellLowThreshold) {
        alarms.add(BmsMalfunction(
          source: "Cell #${i + 1}",
          value: v.toStringAsFixed(3),
          unit: "V",
          token: "cellUvp",
        ));
      } else if (v > BmsBaseInfo.cellHighThreshold) {
        alarms.add(BmsMalfunction(
          source: "Cell #${i + 1}",
          value: v.toStringAsFixed(3),
          unit: "V",
          token: "cellOvp",
        ));
      }
    }
    return alarms;
  }

  factory BmsCellVoltages.fromBytes(List<int> data) {
    List<double> voltages = [];
    for (int i = 0; i < data.length; i += 2) {
      if (i + 1 < data.length) {
        int vRaw = (data[i] << 8) | data[i + 1];
        voltages.add(vRaw / 1000.0);
      }
    }
    return BmsCellVoltages(voltages: voltages);
  }
}

class BmsHardwareVersion {
  final String version;

  BmsHardwareVersion({required this.version});

  factory BmsHardwareVersion.fromBytes(List<int> data) {
    String version = String.fromCharCodes(data);
    return BmsHardwareVersion(version: version);
  }
}

class BmsDeviceInfo {
  final String serialNumber;
  final String barcode;
  final String manufacturer;
  final String batteryModel;
  final String bmsModel;
  final String bmsAddress;
  final double ratedChargeCurrent;
  final double ratedDischargeCurrent;
  final double ratedDischargePower;

  BmsDeviceInfo({
    this.serialNumber = '',
    this.barcode = '',
    this.manufacturer = '',
    this.batteryModel = '',
    this.bmsModel = '',
    this.bmsAddress = '',
    this.ratedChargeCurrent = 0,
    this.ratedDischargeCurrent = 0,
    this.ratedDischargePower = 0,
  });

  BmsDeviceInfo copyWith({
    String? serialNumber,
    String? barcode,
    String? manufacturer,
    String? batteryModel,
    String? bmsModel,
    String? bmsAddress,
    double? ratedChargeCurrent,
    double? ratedDischargeCurrent,
    double? ratedDischargePower,
  }) {
    return BmsDeviceInfo(
      serialNumber: serialNumber ?? this.serialNumber,
      barcode: barcode ?? this.barcode,
      manufacturer: manufacturer ?? this.manufacturer,
      batteryModel: batteryModel ?? this.batteryModel,
      bmsModel: bmsModel ?? this.bmsModel,
      bmsAddress: bmsAddress ?? this.bmsAddress,
      ratedChargeCurrent: ratedChargeCurrent ?? this.ratedChargeCurrent,
      ratedDischargeCurrent: ratedDischargeCurrent ?? this.ratedDischargeCurrent,
      ratedDischargePower: ratedDischargePower ?? this.ratedDischargePower,
    );
  }

  factory BmsDeviceInfo.fromSerialBytes(List<int> data) {
    if (data.length >= 2) {
      int serial = (data[0] << 8) | data[1];
      return BmsDeviceInfo(serialNumber: serial.toString());
    }
    return BmsDeviceInfo();
  }

  factory BmsDeviceInfo.fromBarcodeBytes(List<int> data) {
    return BmsDeviceInfo(barcode: _decodeGb2312(data));
  }

  factory BmsDeviceInfo.fromManufacturerBytes(List<int> data) {
    return BmsDeviceInfo(manufacturer: _decodeGb2312(data));
  }

  factory BmsDeviceInfo.fromBatteryModelBytes(List<int> data) {
    return BmsDeviceInfo(batteryModel: _decodeGb2312(data));
  }

  static String _decodeGb2312(List<int> bytes) {
    return String.fromCharCodes(bytes.where((b) => b >= 0x20 && b <= 0x7E).toList());
  }
}
