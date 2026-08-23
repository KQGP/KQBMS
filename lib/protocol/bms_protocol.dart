// ignore_for_file: constant_identifier_names

import 'crc_utils.dart';

class BmsProtocol {
  static const int HEADER = 0xDD;
  static const int TAIL = 0x77;

  static const int ACTION_READ = 0xA5;
  static const int ACTION_WRITE = 0x5A;

  static const int CMD_READ_BASE_INFO = 0x03;
  static const int CMD_READ_CELL_VOLTAGES = 0x04;
  static const int CMD_READ_HARDWARE_VERSION = 0x05;
  static const int CMD_MOS_CONTROL = 0xE1;
  static const int CMD_RESET_PASSWORD = 0x00;
  static const int CMD_FACTORY_MODE = 0x00;
  static const int CMD_CLOSE_FACTORY_MODE = 0x01;
  static const int CMD_SERIAL_NUMBER = 0x16;
  static const int CMD_CALIBRATION_STATUS = 0x64;
  static const int CMD_EXTENDED_PARAMS = 0xFA;
  static const int CMD_MANUFACTURER = 0xA0;
  static const int CMD_BATTERY_MODEL = 0xA1;
  static const int CMD_BARCODE = 0xA2;

  static const int AUTH_HEADER = 0xFF;
  static const int AUTH_SECOND_BYTE = 0xAA;
  static const int AUTH_TAIL = 0x77;

  static const int AUTH_CMD_SEND_APP_KEY = 0x15;
  static const int AUTH_CMD_CHANGE_PASSWORD = 0x16;
  static const int AUTH_CMD_GET_RANDOM = 0x17;
  static const int AUTH_CMD_SEND_PASSWORD = 0x18;
  static const int AUTH_CMD_SEND_ROOT_PASSWORD = 0x1D;

  static List<int> createPacket(
    int action,
    int function, [
    List<int> data = const [],
  ]) {
    int length = data.length;
    List<int> packet = [HEADER, action, function, length, ...data];

    var (high, low) = CrcUtils.calculateRequestChecksum(function, length, data);
    packet.add(high);
    packet.add(low);
    packet.add(TAIL);

    return packet;
  }

  static List<int> createAuthPacket(int command, [List<int> data = const []]) {
    List<int> payload = [command, data.length, ...data];
    int checksum = CrcUtils.calculateAuthChecksum(payload);

    return [AUTH_HEADER, AUTH_SECOND_BYTE, ...payload, checksum];
  }

  static Map<String, dynamic> parseResponse(List<int> packet) {
    if (packet.isEmpty) throw const FormatException("Empty packet");

    if (packet[0] == HEADER) {
      if (packet.length >= 7) {
        int len = packet[3];
        int expectedLen = len + 7;

        if (packet.length >= expectedLen && packet[expectedLen - 1] == TAIL) {
          return _parseStandardPacket(packet.sublist(0, expectedLen));
        }

        if (packet.length == expectedLen && packet.last == TAIL) {
          return _parseStandardPacket(packet);
        }
      }
    }

    if (packet.length >= 4 &&
        packet[0] == AUTH_HEADER &&
        packet[1] == AUTH_SECOND_BYTE) {
      return _parseAuthPacket(packet);
    }

    throw const FormatException("Unknown packet format");
  }

  static Map<String, dynamic> _parseStandardPacket(List<int> packet) {
    if (packet.length < 7) throw const FormatException("Packet too short");

    int command = packet[1];
    int status = packet[2];
    int length = packet[3];

    if (packet.length < length + 7) {
      throw FormatException(
        "Packet incomplete: expected ${length + 7}, got ${packet.length}",
      );
    }

    List<int> data = packet.sublist(4, 4 + length);

    return {
      'type': 'standard',
      'command': command,
      'status': status,
      'data': data,
    };
  }

  static Map<String, dynamic> _parseAuthPacket(List<int> packet) {
    int command = packet[2];
    int length = packet[3];

    List<int> data = [];
    if (packet.length > 4) {
      int availableData = packet.length - 5;
      if (availableData > 0) {
        data = packet.sublist(
          4,
          4 + ((availableData < length) ? availableData : length),
        );
      }
    }

    return {'type': 'auth', 'command': command, 'data': data};
  }

  static List<int> createReadPacket(int function) {
    return createPacket(ACTION_READ, function);
  }

  static List<int> createWritePacket(int address, List<int> data) {
    return createPacket(ACTION_WRITE, address, data);
  }

  static int mosControlValue({
    required bool chargeEnabled,
    required bool dischargeEnabled,
  }) {
    final chargeBit = chargeEnabled ? 0 : 1;
    final dischargeBit = dischargeEnabled ? 0 : 1;
    return (dischargeBit << 1) | chargeBit;
  }

  static List<int> createMosControlPacket(int controlValue) {
    return createWritePacket(CMD_MOS_CONTROL, [0x00, controlValue & 0xFF]);
  }

  static List<int> createFactoryModeOpenPacket() {
    return createWritePacket(CMD_FACTORY_MODE, [0x56, 0x78]);
  }

  static List<int> createFactoryModeClosePacket() {
    return createWritePacket(CMD_CLOSE_FACTORY_MODE, [0x00, 0x00]);
  }

  static List<int> createExtendedReadPacket(int address, int length) {
    return createPacket(ACTION_READ, CMD_EXTENDED_PARAMS, [
      (address >> 8) & 0xFF,
      address & 0xFF,
      length,
    ]);
  }

  static String packetToHex(List<int> packet) {
    return packet
        .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
        .join(' ');
  }
}
