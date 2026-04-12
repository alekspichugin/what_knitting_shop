import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/about/domain/model/about_content.dart';
import 'package:shop/about/presentation/bloc/about_editor_state.dart';
import 'package:shop/common/services/cloudinary_service.dart';

class AboutEditorCubit extends Cubit<AboutEditorState> {
  AboutEditorCubit(this._cloudinary) : super(const AboutEditorState());

  final CloudinaryService _cloudinary;

  void initFrom(AboutContent content) {
    if (state.initialized) return;
    emit(state.copyWith(
      rows: content.rows.map(AboutEditorRow.fromDomain).toList(),
      initialized: true,
    ));
  }

  // ── Structure mutations ───────────────────────────────────────────────────

  void addRow(AboutBlockType type) {
    emit(state.copyWith(rows: [...state.rows, AboutEditorRow.fresh(type)]));
  }

  void addBlockToRow(int rowIndex, AboutBlockType type) {
    final rows = List<AboutEditorRow>.from(state.rows);
    final row = rows[rowIndex];
    rows[rowIndex] = row.copyWith(blocks: [...row.blocks, AboutEditorBlock.fresh(type)]);
    emit(state.copyWith(rows: rows));
  }

  void removeBlock(int rowIndex, int blockIndex) {
    final rows = List<AboutEditorRow>.from(state.rows);
    final blocks = List<AboutEditorBlock>.from(rows[rowIndex].blocks)..removeAt(blockIndex);
    if (blocks.isEmpty) {
      rows.removeAt(rowIndex);
    } else {
      rows[rowIndex] = rows[rowIndex].copyWith(blocks: blocks);
    }
    emit(state.copyWith(rows: rows));
  }

  void removeRow(int rowIndex) {
    final rows = List<AboutEditorRow>.from(state.rows)..removeAt(rowIndex);
    emit(state.copyWith(rows: rows));
  }

  void moveRowUp(int i) {
    if (i <= 0) return;
    final rows = List<AboutEditorRow>.from(state.rows);
    final row = rows.removeAt(i);
    rows.insert(i - 1, row);
    emit(state.copyWith(rows: rows));
  }

  void moveRowDown(int i) {
    if (i >= state.rows.length - 1) return;
    final rows = List<AboutEditorRow>.from(state.rows);
    final row = rows.removeAt(i);
    rows.insert(i + 1, row);
    emit(state.copyWith(rows: rows));
  }

  void moveBlockLeft(int rowIndex, int blockIndex) {
    if (blockIndex <= 0) return;
    final rows = List<AboutEditorRow>.from(state.rows);
    final blocks = List<AboutEditorBlock>.from(rows[rowIndex].blocks);
    final b = blocks.removeAt(blockIndex);
    blocks.insert(blockIndex - 1, b);
    rows[rowIndex] = rows[rowIndex].copyWith(blocks: blocks);
    emit(state.copyWith(rows: rows));
  }

  void moveBlockRight(int rowIndex, int blockIndex) {
    if (blockIndex >= state.rows[rowIndex].blocks.length - 1) return;
    final rows = List<AboutEditorRow>.from(state.rows);
    final blocks = List<AboutEditorBlock>.from(rows[rowIndex].blocks);
    final b = blocks.removeAt(blockIndex);
    blocks.insert(blockIndex + 1, b);
    rows[rowIndex] = rows[rowIndex].copyWith(blocks: blocks);
    emit(state.copyWith(rows: rows));
  }

  // ── Image upload ──────────────────────────────────────────────────────────

  Future<void> uploadImage(int rowIndex, int blockIndex, Uint8List bytes, String filename) async {
    emit(state.copyWith(uploading: true));
    try {
      final publicId = await _cloudinary.uploadImage(bytes, filename);
      setImageId(rowIndex, blockIndex, publicId);
    } catch (_) {}
    emit(state.copyWith(uploading: false));
  }

  void setImageId(int rowIndex, int blockIndex, String publicId) {
    final rows = List<AboutEditorRow>.from(state.rows);
    final blocks = List<AboutEditorBlock>.from(rows[rowIndex].blocks);
    blocks[blockIndex] = blocks[blockIndex].copyWith(imageId: publicId);
    rows[rowIndex] = rows[rowIndex].copyWith(blocks: blocks);
    emit(state.copyWith(rows: rows));
  }

  // ── Build domain model ────────────────────────────────────────────────────

  /// [textValues] — Map<blockId, text> собранный из TextEditingController в UI.
  AboutContent buildContent(Map<String, String> textValues) => AboutContent(
        rows: state.rows
            .map((r) => AboutRow(
                  id: r.id,
                  blocks: r.blocks
                      .map((b) => AboutBlock(
                            id: b.id,
                            type: b.type,
                            content: b.type == AboutBlockType.image
                                ? b.imageId
                                : (textValues[b.id]?.trim() ?? ''),
                          ))
                      .toList(),
                ))
            .toList(),
      );
}
