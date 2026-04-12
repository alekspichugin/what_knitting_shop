import 'dart:convert';

import 'package:shop/product/domain/model/product.dart';

/// Возвращает байты .csv шаблона для импорта товаров.
/// Колонки генерируются из [Product.importFields].
/// imageIds необязателен — можно добавить позже через форму товара.
List<int> buildProductImportTemplate() {
  final header = Product.importFields.join(',');
  // Пример: title заполнен, остальные пустые
  final exampleValues = Product.importFields.map((field) {
    return switch (field) {
      'title' => 'Пряжа мериносовая 100г',
      'description' =>
        'Мягкая пряжа из 100% мериносовой шерсти. Подходит для вязания спицами и крючком.',
      _ => '',
    };
  }).join(',');

  final csv = '$header\r\n$exampleValues\r\n';
  return utf8.encode(csv);
}
