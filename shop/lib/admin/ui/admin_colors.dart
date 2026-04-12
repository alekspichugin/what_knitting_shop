import 'package:flutter/material.dart';

const kAdminColors = <String, Color>{
  'Красный': Colors.redAccent,
  'Оранжевый': Colors.orange,
  'Жёлтый': Colors.amber,
  'Зелёный': Colors.green,
  'Голубой': Colors.lightBlue,
  'Синий': Colors.blue,
  'Фиолетовый': Colors.purple,
  'Розовый': Colors.pink,
  'Бирюзовый': Colors.teal,
  'Индиго': Colors.indigo,
  'Коричневый': Colors.brown,
};

String colorName(Color color) {
  for (final entry in kAdminColors.entries) {
    if (entry.value == color) return entry.key;
  }
  return 'Оранжевый';
}
