import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';

class FirebaseProductRepository implements AbstractProductRepository {
  final _col = FirebaseFirestore.instance.collection('products');

  static const _ttl = Duration(minutes: 10);

  List<Product>? _allCache;
  DateTime? _allCachedAt;
  final Map<String, ({List<Product> data, DateTime cachedAt})> _byIdsCache = {};

  bool get _allCacheValid =>
      _allCache != null &&
      _allCachedAt != null &&
      DateTime.now().difference(_allCachedAt!) < _ttl;

  bool _byIdsCacheValid(String key) {
    final entry = _byIdsCache[key];
    if (entry == null) return false;
    return DateTime.now().difference(entry.cachedAt) < _ttl;
  }

  void _invalidate() {
    _allCache = null;
    _allCachedAt = null;
    _byIdsCache.clear();
  }

  @override
  Future<List<Product>> get({List<int> ids = const []}) async {
    if (ids.isEmpty) {
      if (_allCacheValid) return _allCache!;
      final snap = await _col.orderBy('id').get();
      _allCache = snap.docs.map(_fromDoc).toList();
      _allCachedAt = DateTime.now();
      return _allCache!;
    }

    final key = (List<int>.from(ids)..sort()).join(',');
    if (_byIdsCacheValid(key)) return _byIdsCache[key]!.data;
    final snap = await _col.where('id', whereIn: ids).get();
    final result = snap.docs.map(_fromDoc).toList();
    _byIdsCache[key] = (data: result, cachedAt: DateTime.now());
    return result;
  }

  @override
  Future<Product> create({
    required String title,
    required String description,
    required List<String> imageIds,
    double price = 0,
  }) async {
    final snap = await _col.orderBy('id', descending: true).limit(1).get();
    final nextId = snap.docs.isEmpty ? 0 : (_fromDoc(snap.docs.first).id + 1);
    final product = Product(id: nextId, imageIds: imageIds, title: title, description: description, price: price);
    await _col.doc('$nextId').set(_toMap(product));
    _invalidate();
    return product;
  }

  @override
  Future<void> update(Product product) async {
    await _col.doc('${product.id}').set(_toMap(product));
    _invalidate();
  }

  @override
  Future<void> delete(int id) async {
    await _col.doc('$id').delete();
    _invalidate();
  }

  Product _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<String> imageIds;
    if (data['imageIds'] != null) {
      imageIds = List<String>.from(data['imageIds'] as List);
    } else {
      imageIds = [];
    }
    return Product(
      id: data['id'] as int,
      imageIds: imageIds,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> _toMap(Product p) => {
        'id': p.id,
        'imageIds': p.imageIds,
        'title': p.title,
        'description': p.description,
        'price': p.price,
      };
}
