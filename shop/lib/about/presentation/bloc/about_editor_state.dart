import 'package:shop/about/domain/model/about_content.dart';

class AboutEditorBlock {
  const AboutEditorBlock({
    required this.id,
    required this.type,
    this.imageId = '',
  });

  final String id;
  final AboutBlockType type;
  final String imageId; // используется только для image-блоков

  AboutEditorBlock copyWith({String? imageId}) =>
      AboutEditorBlock(id: id, type: type, imageId: imageId ?? this.imageId);

  static AboutEditorBlock fromDomain(AboutBlock b) => AboutEditorBlock(
        id: b.id,
        type: b.type,
        imageId: b.type == AboutBlockType.image ? b.content : '',
      );

  static AboutEditorBlock fresh(AboutBlockType type) => AboutEditorBlock(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
      );
}

class AboutEditorRow {
  const AboutEditorRow({required this.id, required this.blocks});

  final String id;
  final List<AboutEditorBlock> blocks;

  AboutEditorRow copyWith({List<AboutEditorBlock>? blocks}) =>
      AboutEditorRow(id: id, blocks: blocks ?? this.blocks);

  static AboutEditorRow fromDomain(AboutRow r) => AboutEditorRow(
        id: r.id,
        blocks: r.blocks.map(AboutEditorBlock.fromDomain).toList(),
      );

  static AboutEditorRow fresh(AboutBlockType type) => AboutEditorRow(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        blocks: [AboutEditorBlock.fresh(type)],
      );
}

class AboutEditorState {
  const AboutEditorState({
    this.rows = const [],
    this.uploading = false,
    this.initialized = false,
  });

  final List<AboutEditorRow> rows;
  final bool uploading;
  final bool initialized;

  AboutEditorState copyWith({
    List<AboutEditorRow>? rows,
    bool? uploading,
    bool? initialized,
  }) =>
      AboutEditorState(
        rows: rows ?? this.rows,
        uploading: uploading ?? this.uploading,
        initialized: initialized ?? this.initialized,
      );
}
