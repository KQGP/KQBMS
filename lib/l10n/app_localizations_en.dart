// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KQBMS';

  @override
  String get userName => 'Khalil Anes Alqisy';

  @override
  String get about => 'About';

  @override
  String get appDescriptionSubtitle => 'Jiabaida BMS Companion';

  @override
  String get developedBy => 'Developed by';

  @override
  String get description => 'Description';

  @override
  String get longDescription =>
      'KQBMS is a cross-platform companion app for Jiabaida (JBD) Battery Management Systems. It connects over Bluetooth Low Energy to display real-time battery telemetry, control charge/discharge MOSFETs, and monitor cell status.';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get batteryMonitor => 'Battery Monitor';

  @override
  String get discoverDevices => 'Discover Devices';

  @override
  String get stop => 'Stop';

  @override
  String get scan => 'Scan';

  @override
  String get scanningForDevices => 'Scanning for BMS devices...';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get makeSureBmsPowered =>
      'Make sure your BMS is powered on\nand in range';

  @override
  String get retryScan => 'Retry Scan';

  @override
  String get unknownDevice => 'Unknown Device';

  @override
  String get voltage => 'Voltage';

  @override
  String get current => 'Current';

  @override
  String get cycles => 'Cycles';

  @override
  String get capacity => 'Capacity';

  @override
  String get temp => 'Temp';

  @override
  String get charge => 'Charge';

  @override
  String get discharge => 'Discharge';

  @override
  String get timeToFull => 'Time to full';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get interface => 'Interface';

  @override
  String get device => 'Device';

  @override
  String get settings => 'Settings';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get temperature => 'Temperature';

  @override
  String get refreshInterval => 'Refresh Interval';

  @override
  String get autoReconnect => 'Auto Reconnect';

  @override
  String get details => 'Details';

  @override
  String get cells => 'Cells';

  @override
  String get status => 'Status';

  @override
  String get params => 'Params';

  @override
  String get max => 'Max';

  @override
  String get min => 'Min';

  @override
  String get diff => 'Diff';

  @override
  String get avg => 'Avg';

  @override
  String get balancing => 'Balancing';

  @override
  String get mosfetStatus => 'MOSFET Status';

  @override
  String get protections => 'Protections';

  @override
  String get balanceStatus => 'Balance Status';

  @override
  String get balancingCells => 'Balancing cells';

  @override
  String get none => 'none';

  @override
  String get balanceCurrent => 'Balance current';

  @override
  String get noData => 'No data';

  @override
  String get noActiveProtections => 'No active protections';

  @override
  String get battery => 'Battery';

  @override
  String get nominalCapacity => 'Nominal Capacity';

  @override
  String get remaining => 'Remaining';

  @override
  String get learnedCapacity => 'Learned Capacity';

  @override
  String get soc => 'SOC';

  @override
  String get cycleCount => 'Cycle Count';

  @override
  String get productionDate => 'Production Date';

  @override
  String get electrical => 'Electrical';

  @override
  String get packVoltage => 'Pack Voltage';

  @override
  String get packCurrent => 'Pack Current';

  @override
  String get power => 'Power';

  @override
  String get cellCount => 'Cell Count';

  @override
  String get ntcCount => 'NTC Count';

  @override
  String get identity => 'Identity';

  @override
  String get software => 'Software';

  @override
  String get hardware => 'Hardware';

  @override
  String get serialNumberShort => 'Serial #';

  @override
  String get barcode => 'Barcode';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get batteryModel => 'Battery Model';

  @override
  String get bmsModel => 'BMS Model';

  @override
  String get bmsAddress => 'BMS Address';

  @override
  String get ratings => 'Ratings';

  @override
  String get ratedCharge => 'Rated Charge';

  @override
  String get ratedDischarge => 'Rated Discharge';

  @override
  String get ratedPower => 'Rated Power';

  @override
  String get malfunctions => 'Malfunctions';

  @override
  String get allSystemsNormal => 'All systems normal';

  @override
  String get noMalfunctionsDetected =>
      'No malfunctions or sensor faults detected.';

  @override
  String get cellOvp => 'Cell OVP';

  @override
  String get cellUvp => 'Cell UVP';

  @override
  String get packOvp => 'Pack OVP';

  @override
  String get packUvp => 'Pack UVP';

  @override
  String get chargeOtp => 'Charge OTP';

  @override
  String get chargeUtp => 'Charge UTP';

  @override
  String get dischOtp => 'Disch OTP';

  @override
  String get dischUtp => 'Disch UTP';

  @override
  String get chargeOcp => 'Charge OCP';

  @override
  String get dischOcp => 'Disch OCP';

  @override
  String get shortCkt => 'Short Ckt';

  @override
  String get icError => 'IC Error';

  @override
  String get mosLock => 'MOS Lock';

  @override
  String get overTemperature => 'over temperature';

  @override
  String get sensorFault => 'sensor fault';

  @override
  String get noReading => 'no reading';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'WiFi';

  @override
  String get wifiBridge => 'KQBMS WiFi Bridge';

  @override
  String get wifiBridgeSubtitle =>
      'Connect to your BMS through the ESP32 bridge';

  @override
  String get bridgeAddress => 'Bridge Address';

  @override
  String get bridgeAddressHint => 'kqbms-bridge.local or IP';

  @override
  String get portLabel => 'Port';

  @override
  String get autoDiscover => 'Auto Discover';

  @override
  String get bridgeFound => 'Bridge found';

  @override
  String get bridgeNotFound => 'Bridge not found on this network';

  @override
  String get connect => 'Connect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get enterBridgeAddress => 'Enter the bridge address';
}
