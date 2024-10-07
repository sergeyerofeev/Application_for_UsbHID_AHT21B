import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../provider/provider.dart';
import '../settings/extension.dart';
import '../settings/my_style.dart' as my_style;

class ContentBody extends ConsumerStatefulWidget {
  const ContentBody({super.key});

  @override
  ConsumerState<ContentBody> createState() => _ContentBodyState();
}

class _ContentBodyState extends ConsumerState<ContentBody> {
  @override
  void initState() {
    Future(() => _hidOpen());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final humidityRaw = ref.watch(humidityRawProvider);
    final temperatureRaw = ref.watch(temperatureRawProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          temperatureRaw.toTemperature(),
          textAlign: TextAlign.center,
          style: my_style.tempStyle,
        ),
        Text(
          humidityRaw.toHumidity(),
          textAlign: TextAlign.center,
          style: my_style.humStyle,
        ),
      ],
    );
  }

  // Пытаемся подключиться к usb устройству
  void _hidOpen() {
    if (hid.open() != 0) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (hid.open() == 0) {
          // Установим статус поключения, true - связь с устройством установлена
          ref.read(connectProvider.notifier).state = true;
          timer.cancel();
          _hidRead();
        }
      });
    } else {
      // Ожидание установки соединенения не требуется
      // Установим статус поключения в true
      ref.read(connectProvider.notifier).state = true;
      _hidRead();
    }
  }

  void _hidRead() async {
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        final rawData = await hid.read(timeout: 10);
        // Если получили null, значит произошло отключение usb устройства
        if (rawData == null) {
          // Установим rawDataProvider в null для обнуления показаний в окне вывода
          ref.read(humidityRawProvider.notifier).state = null;
          ref.read(temperatureRawProvider.notifier).state = null;
          throw Exception();
        }
        if (rawData.isNotEmpty) {
          // Данные получены, преобразуем и передаём в провайдеры
          int raw = rawData[0] << 16 | rawData[1] << 8 | rawData[2];
          ref.read(humidityRawProvider.notifier).state = raw;

          raw = rawData[3] << 16 | rawData[4] << 8 | rawData[5];
          ref.read(temperatureRawProvider.notifier).state = raw;
        }
        // Получили пустой массив rawData, нет данных
      } catch (e) {
        // Устанавливаем статус подключения в false
        ref.read(connectProvider.notifier).state = false;
        timer.cancel();
        hid.close();
        _hidOpen();
      }
    });
  }
}
