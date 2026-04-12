import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shop/about/domain/model/about_content.dart';
import 'package:shop/about/presentation/bloc/about_cubit.dart';
import 'package:shop/common/cloudinary.dart';
import 'package:web/web.dart' as web;

const _kCloudName   = 'db7wmn9yi';
const _kPreset      = 'what_kniting_products';
const _kBrand       = Color(0xFF7C3AED);
const _kBrandLight  = Color(0xFFEDE9FE);
const _kBrandMedium = Color(0xFFF5F3FF);
const _kBorder      = Color(0xFFE5E7EB);
const _kGray        = Color(0xFF9CA3AF);

// ─── Local state ─────────────────────────────────────────────────────────────

class _BlockData {
  _BlockData({required this.id, required this.type, TextEditingController? ctrl, this.imageId})
      : ctrl = ctrl ?? (type != AboutBlockType.image ? TextEditingController() : null);

  final String id;
  final AboutBlockType type;
  final TextEditingController? ctrl;
  String? imageId;

  factory _BlockData.fromBlock(AboutBlock b) => _BlockData(
        id: b.id,
        type: b.type,
        ctrl: b.type != AboutBlockType.image ? TextEditingController(text: b.content) : null,
        imageId: b.type == AboutBlockType.image ? b.content : null,
      );

  factory _BlockData.fresh(AboutBlockType type) => _BlockData(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
      );

  void dispose() => ctrl?.dispose();
}

class _RowData {
  _RowData({required this.id, required this.blocks});
  final String id;
  final List<_BlockData> blocks;

  factory _RowData.fresh(AboutBlockType type) => _RowData(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        blocks: [_BlockData.fresh(type)],
      );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AboutEditorPage extends StatefulWidget {
  const AboutEditorPage({super.key});

  @override
  State<AboutEditorPage> createState() => _AboutEditorPageState();
}

class _AboutEditorPageState extends State<AboutEditorPage> {
  final List<_RowData> _rows = [];
  bool _initialized = false;
  bool _uploading = false;

  @override
  void dispose() {
    for (final row in _rows) {
      for (final b in row.blocks) b.dispose();
    }
    super.dispose();
  }

  void _initFrom(AboutContent content) {
    if (_initialized) return;
    _initialized = true;
    for (final row in content.rows) {
      _rows.add(_RowData(
        id: row.id,
        blocks: row.blocks.map(_BlockData.fromBlock).toList(),
      ));
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  void _addNewRow(AboutBlockType type) {
    setState(() => _rows.add(_RowData.fresh(type)));
  }

  void _addBlockToRow(int ri, AboutBlockType type) {
    setState(() => _rows[ri].blocks.add(_BlockData.fresh(type)));
  }

  void _removeBlock(int ri, int bi) {
    setState(() {
      _rows[ri].blocks[bi].dispose();
      _rows[ri].blocks.removeAt(bi);
      if (_rows[ri].blocks.isEmpty) _rows.removeAt(ri);
    });
  }

  void _removeRow(int ri) {
    setState(() {
      for (final b in _rows[ri].blocks) b.dispose();
      _rows.removeAt(ri);
    });
  }

  void _moveRowUp(int i) {
    if (i <= 0) return;
    setState(() {
      final row = _rows.removeAt(i);
      _rows.insert(i - 1, row);
    });
  }

  void _moveRowDown(int i) {
    if (i >= _rows.length - 1) return;
    setState(() {
      final row = _rows.removeAt(i);
      _rows.insert(i + 1, row);
    });
  }

  void _moveBlockLeft(int ri, int bi) {
    if (bi <= 0) return;
    setState(() {
      final b = _rows[ri].blocks.removeAt(bi);
      _rows[ri].blocks.insert(bi - 1, b);
    });
  }

  void _moveBlockRight(int ri, int bi) {
    if (bi >= _rows[ri].blocks.length - 1) return;
    setState(() {
      final b = _rows[ri].blocks.removeAt(bi);
      _rows[ri].blocks.insert(bi + 1, b);
    });
  }

  // ── Image upload ───────────────────────────────────────────────────────────

  Future<void> _pickAndUpload(int ri, int bi) async {
    final file = await _pickImageFile();
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_kCloudName/image/upload');
      final req = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _kPreset
        ..files.add(http.MultipartFile.fromBytes('file', file.bytes, filename: file.name));
      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200 && mounted) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        setState(() => _rows[ri].blocks[bi].imageId = json['public_id'] as String);
      }
    } catch (_) {}
    if (mounted) setState(() => _uploading = false);
  }

  Future<({Uint8List bytes, String name})?> _pickImageFile() {
    final c = Completer<({Uint8List bytes, String name})?>();
    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = 'image/*';
    input.style.cssText = 'position:fixed;top:-9999px;left:-9999px;';
    web.document.body!.append(input);
    input.addEventListener('change', (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        input.remove();
        if (!c.isCompleted) c.complete(null);
        return;
      }
      final file = files.item(0)!;
      final reader = web.FileReader();
      reader.addEventListener('load', (web.Event _) {
        final buf = (reader.result as JSArrayBuffer).toDart;
        input.remove();
        if (!c.isCompleted) c.complete((bytes: buf.asUint8List(), name: file.name));
      }.toJS);
      reader.addEventListener('error', (web.Event _) {
        input.remove();
        if (!c.isCompleted) c.complete(null);
      }.toJS);
      reader.readAsArrayBuffer(file);
    }.toJS);
    input.click();
    return c.future;
  }

  // ── Serialize & save ───────────────────────────────────────────────────────

  AboutContent _buildContent() => AboutContent(
        rows: _rows
            .map((r) => AboutRow(
                  id: r.id,
                  blocks: r.blocks
                      .map((b) => AboutBlock(
                            id: b.id,
                            type: b.type,
                            content: b.type == AboutBlockType.image
                                ? (b.imageId ?? '')
                                : (b.ctrl?.text.trim() ?? ''),
                          ))
                      .toList(),
                ))
            .toList(),
      );

  void _save() {
    context.read<AboutCubit>().save(_buildContent());
    context.go('/about');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AboutCubit, AboutState>(
      listener: (context, state) {
        if (state is AboutLoaded) _initFrom(state.content);
      },
      builder: (context, state) {
        if (state is AboutLoaded) _initFrom(state.content);
        final saving = state is AboutSaving;
        final busy = saving || _uploading;

        return Column(
          children: [
            _Header(busy: busy, onSave: _save, onBack: () => context.go('/about')),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Sidebar(),
                  const VerticalDivider(width: 1, thickness: 1, color: _kBorder),
                  Expanded(
                    child: _Canvas(
                      rows: _rows,
                      onDropNew: _addNewRow,
                      onDropToRow: _addBlockToRow,
                      onRemoveRow: _removeRow,
                      onMoveRowUp: _moveRowUp,
                      onMoveRowDown: _moveRowDown,
                      onRemoveBlock: _removeBlock,
                      onMoveBlockLeft: _moveBlockLeft,
                      onMoveBlockRight: _moveBlockRight,
                      onPickImage: _pickAndUpload,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.busy, required this.onSave, required this.onBack});
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: onBack,
            tooltip: 'Назад',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Редактор страницы «О нас»',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: busy ? null : onSave,
            icon: busy
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 16),
            label: const Text('Сохранить'),
            style: FilledButton.styleFrom(backgroundColor: _kBrand),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'БЛОКИ',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kGray, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            for (final type in AboutBlockType.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SidebarItem(type: type),
              ),
            const SizedBox(height: 16),
            const Text(
              'Перетащите блок\nна холст или\nв существующую строку',
              style: TextStyle(fontSize: 11, color: _kGray, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.type});
  final AboutBlockType type;

  @override
  Widget build(BuildContext context) {
    final chip = _SidebarChip(type: type);
    return Draggable<AboutBlockType>(
      data: type,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: _SidebarChip(type: type, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}

class _SidebarChip extends StatelessWidget {
  const _SidebarChip({required this.type, this.dragging = false});
  final AboutBlockType type;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dragging ? _kBrandLight : Colors.white,
        border: Border.all(color: dragging ? _kBrand : _kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_typeIcon(type), size: 15, color: _kBrand),
          const SizedBox(width: 8),
          Text(_typeLabel(type), style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

// ─── Canvas ───────────────────────────────────────────────────────────────────

class _Canvas extends StatelessWidget {
  const _Canvas({
    required this.rows,
    required this.onDropNew,
    required this.onDropToRow,
    required this.onRemoveRow,
    required this.onMoveRowUp,
    required this.onMoveRowDown,
    required this.onRemoveBlock,
    required this.onMoveBlockLeft,
    required this.onMoveBlockRight,
    required this.onPickImage,
  });

  final List<_RowData> rows;
  final ValueChanged<AboutBlockType> onDropNew;
  final void Function(int ri, AboutBlockType type) onDropToRow;
  final ValueChanged<int> onRemoveRow;
  final ValueChanged<int> onMoveRowUp;
  final ValueChanged<int> onMoveRowDown;
  final void Function(int ri, int bi) onRemoveBlock;
  final void Function(int ri, int bi) onMoveBlockLeft;
  final void Function(int ri, int bi) onMoveBlockRight;
  final void Function(int ri, int bi) onPickImage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            _RowCard(
              key: ValueKey(rows[i].id),
              row: rows[i],
              rowIndex: i,
              rowCount: rows.length,
              onDrop: (type) => onDropToRow(i, type),
              onRemove: () => onRemoveRow(i),
              onMoveUp: () => onMoveRowUp(i),
              onMoveDown: () => onMoveRowDown(i),
              onRemoveBlock: (bi) => onRemoveBlock(i, bi),
              onMoveBlockLeft: (bi) => onMoveBlockLeft(i, bi),
              onMoveBlockRight: (bi) => onMoveBlockRight(i, bi),
              onPickImage: (bi) => onPickImage(i, bi),
            ),
          const SizedBox(height: 12),
          _DropZone(onDrop: onDropNew),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Row card ─────────────────────────────────────────────────────────────────

class _RowCard extends StatelessWidget {
  const _RowCard({
    super.key,
    required this.row,
    required this.rowIndex,
    required this.rowCount,
    required this.onDrop,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemoveBlock,
    required this.onMoveBlockLeft,
    required this.onMoveBlockRight,
    required this.onPickImage,
  });

  final _RowData row;
  final int rowIndex;
  final int rowCount;
  final ValueChanged<AboutBlockType> onDrop;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<int> onRemoveBlock;
  final ValueChanged<int> onMoveBlockLeft;
  final ValueChanged<int> onMoveBlockRight;
  final ValueChanged<int> onPickImage;

  @override
  Widget build(BuildContext context) {
    return DragTarget<AboutBlockType>(
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (ctx, candidates, _) {
        final over = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: over ? _kBrandMedium : Colors.white,
            border: Border.all(color: over ? _kBrand : _kBorder, width: over ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row toolbar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                child: Row(
                  children: [
                    const Icon(Icons.drag_handle, size: 16, color: Color(0xFFD1D5DB)),
                    const SizedBox(width: 6),
                    Text('Строка ${rowIndex + 1}',
                        style: const TextStyle(fontSize: 11, color: _kGray)),
                    const Spacer(),
                    if (rowIndex > 0) _Btn(icon: Icons.keyboard_arrow_up, onTap: onMoveUp, tip: 'Вверх'),
                    if (rowIndex < rowCount - 1) _Btn(icon: Icons.keyboard_arrow_down, onTap: onMoveDown, tip: 'Вниз'),
                    const SizedBox(width: 4),
                    _Btn(icon: Icons.delete_outline, onTap: onRemove, tip: 'Удалить строку', color: const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              // Blocks
              Padding(
                padding: const EdgeInsets.all(12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var bi = 0; bi < row.blocks.length; bi++) ...[
                        if (bi > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _BlockCard(
                            block: row.blocks[bi],
                            blockIndex: bi,
                            blockCount: row.blocks.length,
                            onDelete: () => onRemoveBlock(bi),
                            onMoveLeft: bi > 0 ? () => onMoveBlockLeft(bi) : null,
                            onMoveRight: bi < row.blocks.length - 1 ? () => onMoveBlockRight(bi) : null,
                            onPickImage: () => onPickImage(bi),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Block card ───────────────────────────────────────────────────────────────

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.blockCount,
    required this.onDelete,
    required this.onPickImage,
    this.onMoveLeft,
    this.onMoveRight,
  });

  final _BlockData block;
  final int blockIndex;
  final int blockCount;
  final VoidCallback onDelete;
  final VoidCallback onPickImage;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _TypeBadge(type: block.type),
              const Spacer(),
              if (onMoveLeft != null) _Btn(icon: Icons.chevron_left, onTap: onMoveLeft!, tip: 'Влево', size: 14),
              if (onMoveRight != null) _Btn(icon: Icons.chevron_right, onTap: onMoveRight!, tip: 'Вправо', size: 14),
              _Btn(icon: Icons.close, onTap: onDelete, tip: 'Удалить', size: 14, color: const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 8),
          _BlockContent(block: block, onPickImage: onPickImage),
        ],
      ),
    );
  }
}

// ─── Block content ────────────────────────────────────────────────────────────

class _BlockContent extends StatelessWidget {
  const _BlockContent({super.key, required this.block, required this.onPickImage});
  final _BlockData block;
  final VoidCallback onPickImage;

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _kBrand)),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case AboutBlockType.heading:
        return TextFormField(
          controller: block.ctrl,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          decoration: _dec('Заголовок...'),
          maxLines: 1,
        );
      case AboutBlockType.text:
        return TextFormField(
          controller: block.ctrl,
          decoration: _dec('Текст...'),
          maxLines: 5,
          minLines: 3,
        );
      case AboutBlockType.image:
        final id = block.imageId ?? '';
        if (id.isNotEmpty) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  cloudinaryUrl(id, size: CloudinarySize.thumbnail),
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.edit, size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }
        return GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: _kGray, size: 22),
                  SizedBox(height: 4),
                  Text('Загрузить фото', style: TextStyle(fontSize: 11, color: _kGray)),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// ─── Drop zone (new row) ─────────────────────────────────────────────────────

class _DropZone extends StatelessWidget {
  const _DropZone({required this.onDrop});
  final ValueChanged<AboutBlockType> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<AboutBlockType>(
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (ctx, candidates, _) {
        final over = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 72,
          decoration: BoxDecoration(
            color: over ? _kBrandMedium : const Color(0xFFFAFAFA),
            border: Border.all(
              color: over ? _kBrand : _kBorder,
              width: over ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 16, color: over ? _kBrand : _kGray),
                const SizedBox(width: 8),
                Text(
                  'Перетащите блок сюда — создаст новую строку',
                  style: TextStyle(fontSize: 13, color: over ? _kBrand : _kGray),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final AboutBlockType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _kBrandLight, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_typeIcon(type), size: 11, color: _kBrand),
          const SizedBox(width: 4),
          Text(_typeLabel(type),
              style: const TextStyle(fontSize: 10, color: _kBrand, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap, required this.tip, this.size = 16.0, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final String tip;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: size, color: color ?? const Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

IconData _typeIcon(AboutBlockType t) => switch (t) {
      AboutBlockType.heading => Icons.title,
      AboutBlockType.text    => Icons.notes,
      AboutBlockType.image   => Icons.image_outlined,
    };

String _typeLabel(AboutBlockType t) => switch (t) {
      AboutBlockType.heading => 'Заголовок',
      AboutBlockType.text    => 'Текст',
      AboutBlockType.image   => 'Фото',
    };
