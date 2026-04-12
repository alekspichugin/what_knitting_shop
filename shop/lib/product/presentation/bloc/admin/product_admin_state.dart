import 'package:shop/product/domain/model/product.dart';

abstract class ProductAdminState {}

class ProductAdminLoading extends ProductAdminState {}

class ProductAdminLoaded extends ProductAdminState {
  ProductAdminLoaded(this.products);
  final List<Product> products;
}

class ProductAdminError extends ProductAdminState {
  ProductAdminError(this.message);
  final String message;
}

class ProductAdminImporting extends ProductAdminState {
  ProductAdminImporting({required this.current, required this.total});
  final int current;
  final int total;
}

class ProductAdminImportDone extends ProductAdminState {
  ProductAdminImportDone({required this.created, required this.failed});
  final int created;
  final int failed;
}
