import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider.dart';
import '../settings/my_style.dart';

class ContentBody extends ConsumerWidget {
  const ContentBody({super.key});

  String getTemperatureSting(double? data) {
    if (data == null) {
      return '0';
    }
    return (data > 0)
        ? '+${data.toStringAsFixed(1)} \u00BAC'
        : '${data.toStringAsFixed(1)} \u00BAC';
  }

  String getHumiditySting(double? data) {
    if (data == null) {
      return '0';
    }
    return '${data.toStringAsFixed(1)} %';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurement = ref.watch(measurementProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getTemperatureSting(measurement?.temperature),
          textAlign: TextAlign.center,
          style: MyStyle.tempStyle,
        ),
        Text(
          getHumiditySting(measurement?.humidity),
          textAlign: TextAlign.center,
          style: MyStyle.humStyle,
        ),
      ],
    );
  }
}
