class ViewProduct {
  ViewProduct({
    required this.id,
    required this.imageIds,
    required this.title,
    required this.description,
    this.price = 0,
  });

  final int id;
  final List<String> imageIds;
  final String title;
  final String description;
  final double price;

  String get imageId => imageIds.isNotEmpty ? imageIds.first : '';
}
