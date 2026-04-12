import 'package:shop/product/domain/model/product.dart';

abstract class AbstractProductRepository {
  Future<List<Product>> get({List<int> ids});
  Future<Product> create({required String title, required String description, required List<String> imageIds});
  Future<void> update(Product product);
  Future<void> delete(int id);
}
