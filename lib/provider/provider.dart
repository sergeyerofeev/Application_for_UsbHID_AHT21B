import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/i_data_base.dart';

// Провайдер хранилища данных
final storageProvider = Provider<IDataBase>((ref) => throw UnimplementedError());

// Провайдер состояния подключения USB: true - подключено, false - обрыв соединения
final connectProvider = StateProvider.autoDispose<bool>((ref) => false);

// Провайдер значения влажности
final humidityProvider = StateProvider.autoDispose<double>((ref) => 0);

// Провайдер значения температуры
final temperatureProvider = StateProvider.autoDispose<double>((ref) => 0);
