import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/about/domain/abstract_about_repository.dart';
import 'package:shop/about/domain/model/about_content.dart';

class FirebaseAboutRepository implements AbstractAboutRepository {
  final _doc = FirebaseFirestore.instance.collection('about').doc('content');

  static const _ttl = Duration(minutes: 10);

  AboutContent? _cache;
  DateTime? _cachedAt;

  bool get _cacheValid =>
      _cache != null &&
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _ttl;

  void _invalidate() {
    _cache = null;
    _cachedAt = null;
  }

  @override
  Future<AboutContent> get() async {
    if (_cacheValid) return _cache!;
    final snap = await _doc.get();
    if (!snap.exists) {
      _cache = AboutContent(rows: []);
      _cachedAt = DateTime.now();
      return _cache!;
    }
    _cache = _fromDoc(snap.data()!);
    _cachedAt = DateTime.now();
    return _cache!;
  }

  @override
  Future<void> save(AboutContent content) async {
    await _doc.set(_toMap(content));
    _invalidate();
  }

  AboutContent _fromDoc(Map<String, dynamic> data) {
    final rawRows = data['rows'] as List<dynamic>? ?? [];
    final rows = rawRows.map((r) {
      final rm = r as Map<String, dynamic>;
      final rawBlocks = rm['blocks'] as List<dynamic>? ?? [];
      final blocks = rawBlocks.map((b) {
        final bm = b as Map<String, dynamic>;
        final typeStr = bm['type'] as String? ?? 'text';
        final type = AboutBlockType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => AboutBlockType.text,
        );
        return AboutBlock(
          id: bm['id'] as String? ?? '',
          type: type,
          content: bm['content'] as String? ?? '',
        );
      }).toList();
      return AboutRow(id: rm['id'] as String? ?? '', blocks: blocks);
    }).toList();
    return AboutContent(rows: rows);
  }

  Map<String, dynamic> _toMap(AboutContent c) => {
        'rows': c.rows
            .map((r) => {
                  'id': r.id,
                  'blocks': r.blocks
                      .map((b) => {
                            'id': b.id,
                            'type': b.type.name,
                            'content': b.content,
                          })
                      .toList(),
                })
            .toList(),
      };
}
