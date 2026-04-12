import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/product_group/domain/abstract_product_group_repository.dart';
import 'package:shop/product_group/domain/model/product_group.dart';

class FirebaseProductGroupRepository implements AbstractProductGroupRepository {
  final _col = FirebaseFirestore.instance.collection('product_groups');

  static const _ttl = Duration(minutes: 10);

  List<ProductGroup>? _allCache;
  DateTime? _allCachedAt;
  final Map<int, ({ProductGroup data, DateTime cachedAt})> _byIdCache = {};

  bool get _allCacheValid =>
      _allCache != null &&
      _allCachedAt != null &&
      DateTime.now().difference(_allCachedAt!) < _ttl;

  bool _byIdCacheValid(int id) {
    final entry = _byIdCache[id];
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) < _ttl;
  }

  void _invalidate() {
    _allCache = null;
    _allCachedAt = null;
    _byIdCache.clear();
  }

  @override
  Future<List<ProductGroup>> get() async {
    if (_allCacheValid) return _allCache!;
    final snap = await _col.orderBy('id').get();
    _allCache = snap.docs.map(_fromDoc).toList();
    _allCachedAt = DateTime.now();
    return _allCache!;
  }

  @override
  Future<ProductGroup?> getById(int id) async {
    if (_byIdCacheValid(id)) return _byIdCache[id]!.data;
    final doc = await _col.doc('$id').get();
    if (!doc.exists) return null;
    final group = _fromDoc(doc);
    _byIdCache[id] = (data: group, cachedAt: DateTime.now());
    return group;
  }

  @override
  Future<ProductGroup> create({
    required String title,
    required String description,
    required Color color,
    required List<int> productIds,
    String imageUrl = '',
  }) async {
    final snap = await _col.orderBy('id', descending: true).limit(1).get();
    final nextId = snap.docs.isEmpty ? 0 : (_fromDoc(snap.docs.first).id + 1);
    final group = ProductGroup(
      id: nextId,
      title: title,
      description: description,
      color: color,
      productIds: productIds,
      imageUrl: imageUrl,
    );
    await _col.doc('$nextId').set(_toMap(group));
    _invalidate();
    return group;
  }

  @override
  Future<void> update(ProductGroup group) async {
    await _col.doc('${group.id}').set(_toMap(group));
    _invalidate();
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc('$id').delete();
    _invalidate();
  }

  ProductGroup _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductGroup(
      id: data['id'] as int,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      color: Color(data['color'] as int),
      productIds: List<int>.from(data['productIds'] ?? []),
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> _toMap(ProductGroup g) => {
        'id': g.id,
        'title': g.title,
        'description': g.description,
        'color': g.color.value,
        'productIds': g.productIds,
        'imageUrl': g.imageUrl,
      };
}
