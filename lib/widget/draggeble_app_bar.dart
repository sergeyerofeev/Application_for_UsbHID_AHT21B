import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../provider/provider.dart';
import '../settings/key_store.dart';

class DraggebleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DraggebleAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              enableResizeEdges: const [
                ResizeEdge.topLeft,
                ResizeEdge.top,
                ResizeEdge.topRight,
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                      final dx = await ref.read(storageProvider).get<double>(KeyStore.offsetX);
                      final dy = await ref.read(storageProvider).get<double>(KeyStore.offsetY);
                      // Сохраняем, только если значения изменились
                      if (dx != position.dx) {
                        await ref.read(storageProvider).set<double>(KeyStore.offsetX, position.dx);
                      }
                      if (dy != position.dy) {
                        await ref.read(storageProvider).set<double>(KeyStore.offsetY, position.dy);
                      }
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
