import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final rawDataProvider = StateNotifierProvider.autoDispose<RawData, Uint8List?>((ref) => RawData());

class RawData extends StateNotifier<Uint8List?> {
  RawData() : super(null);

  // На основе переданного создаём новый массив Uint8List
  void create(Uint8List receivedData) {
    state = Uint8List.fromList(receivedData);
  }
}
