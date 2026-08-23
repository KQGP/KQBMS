/// Reassembles raw JBD frames (DD .. 77) from an arbitrary byte stream.
///
/// Shared by both transports: BLE notifications may split frames across
/// packets, and TCP chunks can contain partial, whole, or multiple frames
/// concatenated. This parser handles all cases by buffering bytes and
/// extracting complete frames based on the length header.
class FrameAssembler {
  final void Function(List<int> packet) onPacket;

  FrameAssembler({required this.onPacket});

  final List<int> _buffer = [];

  static const int _maxFrameSize = 100;

  void push(List<int> data) {
    try {
      if (_buffer.isEmpty && data.length >= 7 &&
          data[0] == 0xDD && data[data.length - 1] == 0x77) {
        int expectedTotal = data[3] + 7;
        if (data.length == expectedTotal) {
          onPacket(data);
          return;
        }
      }

      _buffer.addAll(data);
      if (_buffer.length > _maxFrameSize * 4) {
        reset();
        return;
      }
      _extractFrames();
    } catch (e) {
      reset();
    }
  }

  void _extractFrames() {
    while (true) {
      if (_buffer.isEmpty) return;

      if (_buffer[0] != 0xDD) {
        final idx = _buffer.indexOf(0xDD);
        if (idx < 0) {
          _buffer.clear();
          return;
        }
        _buffer.removeRange(0, idx);
        continue;
      }

      if (_buffer.length < 4) return;

      final expectedTotal = _buffer[3] + 7;
      if (expectedTotal < 7 || expectedTotal > _maxFrameSize) {
        _buffer.removeAt(0);
        continue;
      }

      if (_buffer.length < expectedTotal) return;

      if (_buffer[expectedTotal - 1] == 0x77) {
        final packet = List<int>.from(_buffer.sublist(0, expectedTotal));
        _buffer.removeRange(0, expectedTotal);
        onPacket(packet);
        continue;
      }

      final tailIdx = _buffer.lastIndexOf(0x77);
      if (tailIdx >= 6) {
        final packet = List<int>.from(_buffer.sublist(0, tailIdx + 1));
        _buffer.removeRange(0, tailIdx + 1);
        onPacket(packet);
        continue;
      }

      _buffer.removeAt(0);
    }
  }

  void reset() {
    _buffer.clear();
  }
}
