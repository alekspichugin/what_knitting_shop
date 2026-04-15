import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shop/common/abstract_state.dart';
import 'package:shop/product/domain/abstract_product_repository.dart';
import 'package:shop/product/domain/model/product.dart';
import 'package:shop/product/presentation/bloc/model/view_product.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {

  static const kCTag = 'ProductDetailsCubit';

  ProductDetailsCubit(
      this._productRepository,
      this._productId
      ) : super(ProductDetailsState());

  final AbstractProductRepository _productRepository;
  final int _productId;

  ViewProduct? _cachedProduct;

  Future load() async {
    final products = await _productRepository.get(ids: [_productId]);

    _cachedProduct = _mapToViewProduct(products.firstOrNull);

    emit(ProductDetailsState(
      product: _cachedProduct
    ));
  }

  ViewProduct? _mapToViewProduct(Product? input) {
    if (input == null) return null;

    return ViewProduct(
        id: input.id,
        imageIds: input.imageIds,
        title: input.title,
        description: input.description,
        price: input.price,
    );
  }
}
