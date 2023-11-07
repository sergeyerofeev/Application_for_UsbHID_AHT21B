import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'data/data_sources/my_storage.dart';
import 'hidapi/hid.dart';
import 'provider/provider.dart';
import 'provider/state_notifier_provider.dart';
import 'settings/key_store.dart';
import 'ui/my_app.dart';

HID hid = HID(idVendor: 1155, idProduct: 22352);
late Uint8List rawData;
final container = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Создаём только один экземпляр приложения
  if (!await FlutterSingleInstance.platform.isFirstInstance()) {
    exit(0);
  }

  await windowManager.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  // Извлекаем из хранилища положение окна на экране монитора
  final double? dx = sharedPreferences.getDouble(KeyStore.offsetX);
  final double? dy = sharedPreferences.getDouble(KeyStore.offsetY);

  const initialSize = Size(160, 130);
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    minimumSize: initialSize,
    maximumSize: initialSize,
    skipTaskbar: false,
    title: 'Монитор \u03C6 % и t \u00BAC',
    titleBarStyle: TitleBarStyle.hidden, // Скрыть панель с кнопками Windows
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Начальное положение окна
    if (dx == null || dy == null) {
      // Если пользователь не выбрал положение окна на экране монитора, размещаем по центру
      await windowManager.center();
    } else {
      await windowManager.setPosition(Offset(dx, dy));
    }
    await windowManager.setAlwaysOnTop(true); // Размещаем приложение поверх других окон
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(
    parent: container,
    overrides: [
      storageProvider.overrideWithValue(MyStorage(sharedPreferences)),
    ],
    child: const MyApp(),
  ));

  Timer(Duration.zero, _hidOpen);
}

// Пытаемся подключиться к usb устройству
void _hidOpen() {
  if (hid.open() != 0) {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (hid.open() == 0) {
        timer.cancel();
        _hidRead();
      }
    });
  } else {
    _hidRead();
  }
}

void _hidRead() async {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      final receivedData = await hid.read(timeout: 100);
      // Если получили null, значит произошло отключение usb устройства
      if (receivedData == null) {
        // Установим rawDataProvider в null для обнуления показаний в окне вывода
        container.refresh(rawDataProvider);
        throw Exception();
      }
      // Получили пустое значение receivedData, нет данных
      if (receivedData.isNotEmpty) {
        container.read(rawDataProvider.notifier).create(receivedData);
      }
    } catch (e) {
      timer.cancel();
      hid.close();
      _hidOpen();
    }
  });
}
