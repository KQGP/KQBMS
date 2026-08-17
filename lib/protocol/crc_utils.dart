class CrcUtils {
  static (int high, int low) calculateRequestChecksum(
    int function,
    int length,
    List<int> data,
  ) {
    int sum = function + length;
    for (int byte in data) {
      sum += byte;
    }

    int checksum = (0x10000 - sum) & 0xFFFF;
    int highByte = (checksum >> 8) & 0xFF;
    int lowByte = checksum & 0xFF;

    return (highByte, lowByte);
  }

  static (int high, int low) calculateResponseChecksum(
    int length,
    List<int> data,
  ) {
    int sum = length;
    for (int byte in data) {
      sum += byte;
    }

    int checksum = (0x10000 - sum) & 0xFFFF;
    int highByte = (checksum >> 8) & 0xFF;
    int lowByte = checksum & 0xFF;

    return (highByte, lowByte);
  }

  static (int high, int low) calculateChecksum(
    int command,
    int modeOrStatus,
    int length,
    List<int> data,
  ) {
    return calculateRequestChecksum(command, length, data);
  }

  static int calculateAuthChecksum(List<int> payload) {
    int checksum = 0;
    for (int byte in payload) {
      checksum += byte;
    }
    return checksum & 0xFF;
  }
}
