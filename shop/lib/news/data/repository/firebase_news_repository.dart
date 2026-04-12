import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/news/domain/abstract_news_repository.dart';
import 'package:shop/news/domain/model/news_item.dart';

class FirebaseNewsRepository implements AbstractNewsRepository {
  final _col = FirebaseFirestore.instance.collection('news');

  static const _ttl = Duration(minutes: 10);

  List<NewsItem>? _cache;
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
  Future<List<NewsItem>> get() async {
    if (_cacheValid) return _cache!;
    final snap = await _col.orderBy('id').get();
    _cache = snap.docs.map(_fromDoc).toList();
    _cachedAt = DateTime.now();
    return _cache!;
  }

  @override
  Future<NewsItem> create({
    required String title,
    required String description,
    required DateTime date,
    required Color color,
  }) async {
    final snap = await _col.orderBy('id', descending: true).limit(1).get();
    final nextId = snap.docs.isEmpty ? 0 : (_fromDoc(snap.docs.first).id + 1);
    final item = NewsItem(
      id: nextId,
      title: title,
      description: description,
      date: date,
      color: color,
    );
    await _col.doc('$nextId').set(_toMap(item));
    _invalidate();
    return item;
  }

  @override
  Future<void> update(NewsItem item) async {
    await _col.doc('${item.id}').set(_toMap(item));
    _invalidate();
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc('$id').delete();
    _invalidate();
  }

  NewsItem _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsItem(
      id: data['id'] as int,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      color: Color(data['color'] as int),
    );
  }

  Map<String, dynamic> _toMap(NewsItem n) => {
        'id': n.id,
        'title': n.title,
        'description': n.description,
        'date': Timestamp.fromDate(n.date),
        'color': n.color.value,
      };
}
