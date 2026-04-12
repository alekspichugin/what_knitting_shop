import 'package:flutter/material.dart';

class ProductGroup {
  ProductGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.productIds,
    this.imageUrl = '',
  });

  final int id;
  final String title;
  final String description;
  final Color color;
  final List<int> productIds;
  final String imageUrl;

  ProductGroup copyWith({
    String? title,
    String? description,
    Color? color,
    List<int>? productIds,
    String? imageUrl,
  }) =>
      ProductGroup(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        color: color ?? this.color,
        productIds: productIds ?? this.productIds,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}
