import 'package:flutter/material.dart';

abstract class MyStyle {
  // Запрещаем создание экземпляров
  MyStyle._();

  static const TextStyle tempStyle = TextStyle(
    fontSize: 30,
    color: Color(0xffaf0000),
    fontWeight: FontWeight.bold,
  );

  static const TextStyle humStyle = TextStyle(
    fontSize: 30,
    color: Color(0xff1d7bc7),
    fontWeight: FontWeight.bold,
  );
}
