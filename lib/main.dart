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
import 'settings/key_store.dart' as key_store;
import 'ui/my_app.dart';

// stm32f103 с модулем датчика температуры и влажности ATH21
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
  final double? dx = sharedPreferences.getDouble(key_store.offsetX);
  final double? dy = sharedPreferences.getDouble(key_store.offsetY);

  const initialSize = Size(175, 130);
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    minimumSize: initialSize,
    maximumSize: initialSize,
    skipTaskbar: false,
    title: 'Монитор \u03C6 % и t \u00BAC',
    // Скрыть панель с кнопками Windows
    titleBarStyle: TitleBarStyle.hidden,
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
    // Запрещаем изменение размеров окна, стрелки на границах окна не отображаются
    await windowManager.setResizable(false);
  });

  runApp(ProviderScope(
    overrides: [
      storageProvider.overrideWith((ref) => MyStorage(sharedPreferences)),
    ],
    child: const MyApp(),
  ));
}
