import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

part 'hidapi_ffi.dart';

/// Wrap around the hid_device pointer.
class HID {
  final int idVendor;
  final int idProduct;
  final String? serial;

  HID({ required this.idVendor, required this.idProduct, this.serial });

  Pointer _device = nullptr;
  bool _nonblocking = false;

  /// Expose the `hid_init` function.
  ///
  /// no need to manually call this, since hidapi will automatically call this during first hid_open.
  static init() => _hidInit();

  /// Expose the `hid_exit` function.
  static exit() => _hidExit();

  /// call `hid_open` to open the specified device.
  ///
  /// return 0 on success, -1 on failure
  int open() {
    Pointer buffer = nullptr.cast();
    using((Arena arena) {
      if (serial != null) {
        var cpcount = serial!.runes.length;
        buffer = allocateWString(cpcount, data: serial, allocator: arena);
      }

      _device = _openDevice(idVendor, idProduct, buffer);
    });

    return _device == nullptr ? -1 : 0;
  }

  void close() {
    if (_device != nullptr) {
      _closeDevice(_device);
    }
  }

  Future<Uint8List?> read({len = 1024, timeout = 0}) async {
    Uint8List? str;
    using((Arena arena) {
      var buffer = arena<Uint8>(len);

      int ret = 0;

      if (timeout > 0) {
        ret = _readDeviceTimeout(_device, buffer, len, timeout);
      } else {
        ret = _readDevice(_device, buffer, len);
      }

      if (ret > 0) {
        str = Uint8List.fromList(buffer.asTypedList(ret));
      } else if (ret == 0) {
        str = Uint8List(0);
      }
    });

    return str;
  }

  Future<int> write(Uint8List data) async {
    assert(data.length < 256);
    int ret = 0;

    using((Arena arena) {
      var buffer = arena<Uint8>(data.length);
      buffer.asTypedList(data.length).setAll(0, data);
      ret = _writeDevice(_device, buffer, data.length);
    });

    return ret;
  }

  set nonblocking(bool val) {
    _nonblocking = val;
    _setNonblocking(_device, val ? 1 : 0);
  }

  bool get nonblocking => _nonblocking;

  Future<int> sendFeatureReport(Uint8List data) async {
    assert(data.length < 256);
    int len = data.length;
    Pointer<Uint8> buffer = calloc<Uint8>(len);
    buffer.asTypedList(len).setAll(0, data);

    int ret = _sendFeatureReport(_device, buffer, len);
    calloc.free(buffer);

    return ret;
  }

  Future<Uint8List?> getFeatureReport(int index, { buffLen = 1024 }) async {
    assert(index < 256);

    Uint8List? res;

    using((Arena arena) {
      Pointer<Uint8> buffer = arena<Uint8>(buffLen);
      buffer.asTypedList(buffLen).fillRange(0, buffLen, 0);
      buffer[0] = index;

      int ret = _getFeatureReport(_device, buffer, buffLen);

      if(ret > 0) {
        res = Uint8List.fromList(buffer.asTypedList(ret));
      }
    });

    return res;
  }

  Future<String?> getManufacturerString({int max = 256}) async {
    String? res;

    using((Arena arena) {
      var buffer = allocateWString(max, allocator: arena);
      int ret = _getManufacturerString(_device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getSerialNumberString({int max = 256}) async {
    String? res;

    using((Arena arena) {
      var buffer = allocateWString(max, allocator: arena);
      int ret = _getSerialNumberString(_device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getProductString({int max = 256}) async {
    String? res;

    using((Arena arena) {
      var buffer = allocateWString(max, allocator: arena);
      int ret = _getProductString(_device, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  Future<String?> getIndexedString(int index, {int max = 256}) async {
    String? res;

    using((Arena arena) {
      var buffer = allocateWString(max, allocator: arena);
      int ret = _getIndexedString(_device, index, buffer, max);
      if(ret == 0) { res = fromWString(buffer); }
    });

    return res;
  }

  String getError() {
    Pointer ptr = _getError(_device);
    if(ptr == nullptr) { return ''; }
    return fromWString(ptr);
  }
}
