class ViewProduct {
  ViewProduct({
    required this.id,
    required this.imageIds,
    required this.title,
    required this.description,
  });

  final int id;
  final List<String> imageIds;
  final String title;
  final String description;

  String get imageId => imageIds.isNotEmpty ? imageIds.first : '';
}
