enum AboutBlockType { heading, text, image }

class AboutBlock {
  AboutBlock({required this.id, required this.type, required this.content});

  final String id;
  final AboutBlockType type;

  /// heading/text → строка; image → Cloudinary public_id
  final String content;

  AboutBlock copyWith({AboutBlockType? type, String? content}) => AboutBlock(
        id: id,
        type: type ?? this.type,
        content: content ?? this.content,
      );
}

class AboutRow {
  AboutRow({required this.id, required this.blocks});

  final String id;
  final List<AboutBlock> blocks;

  AboutRow copyWith({List<AboutBlock>? blocks}) =>
      AboutRow(id: id, blocks: blocks ?? this.blocks);
}

class AboutContent {
  AboutContent({required this.rows});

  final List<AboutRow> rows;

  AboutContent copyWith({List<AboutRow>? rows}) =>
      AboutContent(rows: rows ?? this.rows);
}
