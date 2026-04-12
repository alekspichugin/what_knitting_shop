import 'package:shop/product/domain/model/product.dart';

abstract class AbstractProductRepository {
  /// Вернет все товары
  Future<List<Product>> get();
}