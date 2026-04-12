import 'package:flutter/material.dart';

class NewsItem {
  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  final int id;
  final String title;
  final String description;
  final DateTime date;
  final Color color;

  NewsItem copyWith({
    String? title,
    String? description,
    DateTime? date,
    Color? color,
  }) =>
      NewsItem(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        color: color ?? this.color,
      );
}
