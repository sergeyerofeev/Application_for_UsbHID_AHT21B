import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../provider/provider.dart';
import '../settings/key_store.dart' as key_store;

class DraggebleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DraggebleAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isHidConnect = ref.watch(connectProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xB2F8F8F8),
        border: Border(
          top: BorderSide(
            color: Color(0xff707070),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          getAppBarTitle(),
          SizedBox(
            height: kWindowCaptionHeight,
            child: DragToResizeArea(
              // Даже при глобальном запрете изменять границы окна, верхняя граница
              // будет показывать стрелку, поэтому обнуляем resizeEdgeSize
              resizeEdgeSize: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 46,
                    height: kWindowCaptionHeight,
                    child: isHidConnect
                        ? const Icon(Icons.usb, size: 18.0, color: Colors.green)
                        : const Icon(Icons.usb_off, size: 18.0, color: Colors.red),
                  ),
                  WindowCaptionButton.minimize(
                    onPressed: () async {
                      bool isMinimized = await windowManager.isMinimized();
                      if (isMinimized) {
                        await windowManager.restore();
                      } else {
                        await windowManager.minimize();
                      }
                    },
                  ),
                  WindowCaptionButton.close(
                    onPressed: () async {
                      // Получим и сохраним положение окна на экране монитора
                      final position = await windowManager.getPosition();
                      final dx = await ref.read(storageProvider).get<double>(key_store.offsetX);
                      final dy = await ref.read(storageProvider).get<double>(key_store.offsetY);
                      // Сохраняем, только если значения изменились
                      if (dx != position.dx) {
                        await ref.read(storageProvider).set<double>(key_store.offsetX, position.dx);
                      }
                      if (dy != position.dy) {
                        await ref.read(storageProvider).set<double>(key_store.offsetY, position.dy);
                      }

                      // После всех сохранений закрываем приложение
                      await windowManager.close();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getAppBarTitle() {
    return DragToMoveArea(
      child: Container(
        height: kWindowCaptionHeight,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kWindowCaptionHeight);
}
