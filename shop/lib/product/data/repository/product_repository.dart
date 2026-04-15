import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';

class ProductRepository implements AbstractProductRepository {
  int _nextId = 40;

  final _products = Map<int, Product>.fromEntries(
    List.generate(
      40,
      (index) => MapEntry(
        index,
        Product(id: index, imageIds: const [], title: 'Товар $index', description: ''),
      ),
    ),
  );

  @override
  Future<List<Product>> get({List<int> ids = const <int>[]}) async {
    if (ids.isEmpty) return _products.values.toList();
    return ids.where(_products.containsKey).map((id) => _products[id]!).toList();
  }

  @override
  Future<Product> create({required String title, required String description, required List<String> imageIds, double price = 0}) async {
    final product = Product(id: _nextId, imageIds: imageIds, title: title, description: description, price: price);
    _products[_nextId++] = product;
    return product;
  }

  @override
  Future<void> update(Product product) async {
    _products[product.id] = product;
  }

  @override
  Future<void> delete(int id) async {
    _products.remove(id);
  }
}
