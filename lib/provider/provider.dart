import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/i_data_base.dart';
import '../model/measurement.dart';
import 'state_notifier_provider.dart';

// Провайдер хранилища данных
final storageProvider = Provider<IDataBase>((ref) => throw UnimplementedError());

final measurementProvider = Provider.autoDispose<Measurement?>((ref) {
  final rawData = ref.watch(rawDataProvider);
  if (rawData != null) {
    int raw = rawData[0] << 16 | rawData[1] << 8 | rawData[2];
    // Из полученных данных выводим относительную влажность
    final humidity = raw * 100.00 / 1048576.00;

    raw = rawData[3] << 16 | rawData[4] << 8 | rawData[5];
    // Из полученных данных выводим температуру
    final temperature = (raw * 200.00 / 1048576.00) - 50.00;
    return Measurement(humidity: humidity, temperature: temperature);
  } else {
    return null;
  }
});
