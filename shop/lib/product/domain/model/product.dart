class Product {
  /// Поля, доступные для импорта/экспорта через CSV.
  /// Обновлять при добавлении или удалении полей класса.
  static const importFields = ['title', 'description', 'imageIds'];

  Product({
    required this.id,
    required this.imageIds,
    required this.title,
    required this.description,
  });

  final int id;
  final List<String> imageIds;
  final String title;
  final String description;

  /// public_id первого фото или пустая строка
  String get imageId => imageIds.isNotEmpty ? imageIds.first : '';

  Product copyWith({
    List<String>? imageIds,
    String? title,
    String? description,
  }) =>
      Product(
        id: id,
        imageIds: imageIds ?? this.imageIds,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}
